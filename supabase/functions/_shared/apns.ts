/**
 * Shared APNs HTTP/2 push helper for Supabase Edge Functions (Deno runtime).
 *
 * Requires environment variables:
 *   APNS_KEY_ID       — 10-char key ID from Apple Developer portal
 *   APNS_TEAM_ID      — 10-char Apple Team ID
 *   APNS_PRIVATE_KEY  — PEM-encoded ES256 private key (the .p8 file contents)
 *   APNS_BUNDLE_ID    — iOS app bundle identifier (e.g. com.xomware.float)
 *   APNS_PRODUCTION   — "true" for production, "false" for sandbox
 */

export interface APNsPushOptions {
  deviceToken: string
  title: string
  body: string
  subtitle?: string
  dealId?: string
  venueId?: string
  notificationType?: string
  badge?: number
  sound?: string
  contentAvailable?: boolean  // for silent background pushes
}

export interface APNsResult {
  deviceToken: string
  success: boolean
  apnsId?: string
  error?: string
  invalidToken?: boolean
}

// APNs endpoints
const APNS_PROD_HOST = 'https://api.push.apple.com'
const APNS_DEV_HOST  = 'https://api.sandbox.push.apple.com'

// JWT cache — Apple requires token not to be issued more often than once per minute
let cachedJwt: string | null = null
let jwtIssuedAt: number = 0

/**
 * Sends a push notification to a single APNs device token.
 */
export async function sendAPNsPush(opts: APNsPushOptions): Promise<APNsResult> {
  const {
    deviceToken,
    title,
    body,
    subtitle,
    dealId,
    venueId,
    notificationType,
    badge,
    sound = 'default',
    contentAvailable,
  } = opts

  try {
    const jwt = await getAPNsJwt()
    const isProduction = Deno.env.get('APNS_PRODUCTION') === 'true'
    const host = isProduction ? APNS_PROD_HOST : APNS_DEV_HOST
    const bundleId = Deno.env.get('APNS_BUNDLE_ID') ?? 'com.xomware.float'

    const url = `${host}/3/device/${deviceToken}`

    // Build APNs payload
    const aps: Record<string, unknown> = {
      alert: subtitle ? { title, body, subtitle } : { title, body },
      sound,
    }
    if (badge !== undefined) aps.badge = badge
    if (contentAvailable) aps['content-available'] = 1

    const payload: Record<string, unknown> = { aps }
    if (dealId) payload.deal_id = dealId
    if (venueId) payload.venue_id = venueId
    if (notificationType) payload.notification_type = notificationType

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${jwt}`,
        'apns-topic': bundleId,
        'apns-push-type': contentAvailable ? 'background' : 'alert',
        'apns-priority': contentAvailable ? '5' : '10',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
    })

    const apnsId = response.headers.get('apns-id') ?? undefined

    if (response.status === 200) {
      return { deviceToken, success: true, apnsId }
    }

    // Parse error response
    const errorBody = await response.json().catch(() => ({}))
    const reason: string = errorBody.reason ?? 'UnknownError'

    // Token is permanently invalid — caller should deactivate it
    const invalidToken = reason === 'BadDeviceToken' || reason === 'Unregistered'

    console.warn(`APNs error for ${deviceToken.slice(0, 8)}...: ${reason} (HTTP ${response.status})`)

    return {
      deviceToken,
      success: false,
      apnsId,
      error: reason,
      invalidToken,
    }
  } catch (err) {
    console.error(`APNs push failed for ${deviceToken.slice(0, 8)}...: ${err.message}`)
    return { deviceToken, success: false, error: err.message }
  }
}

// MARK: - JWT Generation

/**
 * Returns a cached APNs JWT, refreshing if older than 45 minutes.
 * Apple requires a new JWT if the current one is older than 60 minutes.
 */
async function getAPNsJwt(): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  const age = now - jwtIssuedAt

  // Refresh if older than 45 minutes (Apple allows up to 60 min)
  if (cachedJwt && age < 45 * 60) {
    return cachedJwt
  }

  const keyId  = Deno.env.get('APNS_KEY_ID') ?? ''
  const teamId = Deno.env.get('APNS_TEAM_ID') ?? ''
  const privateKeyPem = Deno.env.get('APNS_PRIVATE_KEY') ?? ''

  if (!keyId || !teamId || !privateKeyPem) {
    throw new Error('APNs credentials not configured (APNS_KEY_ID, APNS_TEAM_ID, APNS_PRIVATE_KEY)')
  }

  cachedJwt = await signApnsJwt(keyId, teamId, privateKeyPem, now)
  jwtIssuedAt = now
  return cachedJwt
}

/**
 * Signs an APNs JWT using ES256 (ECDSA with P-256 and SHA-256).
 * Header: { alg: "ES256", kid: keyId }
 * Claims: { iss: teamId, iat: now }
 */
async function signApnsJwt(
  keyId: string,
  teamId: string,
  privateKeyPem: string,
  issuedAt: number
): Promise<string> {
  const header = base64url(JSON.stringify({ alg: 'ES256', kid: keyId }))
  const claims = base64url(JSON.stringify({ iss: teamId, iat: issuedAt }))
  const signingInput = `${header}.${claims}`

  // Import the ES256 private key
  const key = await importEC256PrivateKey(privateKeyPem)

  // Sign
  const encoder = new TextEncoder()
  const signature = await crypto.subtle.sign(
    { name: 'ECDSA', hash: { name: 'SHA-256' } },
    key,
    encoder.encode(signingInput)
  )

  return `${signingInput}.${base64urlFromBuffer(signature)}`
}

/**
 * Imports a PEM-encoded PKCS#8 EC private key for use with Web Crypto.
 */
async function importEC256PrivateKey(pem: string): Promise<CryptoKey> {
  // Strip PEM headers and decode base64
  const pemContents = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/-----BEGIN EC PRIVATE KEY-----/, '')
    .replace(/-----END EC PRIVATE KEY-----/, '')
    .replace(/\s+/g, '')

  const binaryDer = Uint8Array.from(atob(pemContents), c => c.charCodeAt(0))

  return crypto.subtle.importKey(
    'pkcs8',
    binaryDer.buffer,
    { name: 'ECDSA', namedCurve: 'P-256' },
    false,
    ['sign']
  )
}

function base64url(str: string): string {
  return btoa(str).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '')
}

function base64urlFromBuffer(buffer: ArrayBuffer): string {
  return btoa(String.fromCharCode(...new Uint8Array(buffer)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '')
}
