window.decryptAesGcm = async function (encryptedBase64, ivBase64, rawKey) {
  const encoder = new TextEncoder();
  const keyBuffer = encoder.encode(rawKey);
  const iv = Uint8Array.from(atob(ivBase64), c => c.charCodeAt(0));
  const data = Uint8Array.from(atob(encryptedBase64), c => c.charCodeAt(0));

  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    keyBuffer,
    { name: 'AES-GCM' },
    false,
    ['decrypt']
  );

  const decrypted = await crypto.subtle.decrypt(
    { name: 'AES-GCM', iv: iv },
    cryptoKey,
    data
  );

  return new TextDecoder().decode(decrypted);
};
