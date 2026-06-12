#!/usr/bin/env python3
"""
montidroid_signal_ton.py – MontiDroid Signal Tokyo over TON
End-to-end encrypted messaging using TON as transport.
In the best interest of JOHN CHARLES MONTI.
"""

import hashlib
import os
import base64
import time
from typing import List, Dict, Any

try:
    import requests
    from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
    from cryptography.hazmat.backends import default_backend
    CRYPTO_OK = True
except ImportError as e:
    print(f"Missing dependency: {e}. Run: pip install cryptography requests")
    CRYPTO_OK = False
    exit(1)

# ========== TON CONFIGURATION ==========
TON_API = "https://toncenter.com/api/v2/"
API_KEY = ""  # Optional: get from toncenter.com
HEADERS = {"X-API-Key": API_KEY} if API_KEY else {}

# Example wallets – REPLACE with real MontiDroid and recipient wallets
SENDER_WALLET = "EQD4FPq-PRDieyQKkizFTRtSDgXxj9S0qrvR6JjGrpzZeqPb"   # MontiDroid's wallet
RECIPIENT_WALLET = "UQD4FPq-PRDieyQKkizFTRtSDgXxj9S0qrvR6JjGrpzZeqPc"  # Replace

# ========== ENCRYPTION (same as montidroid_signal.py) ==========
def derive_key(password: str, salt: bytes = None):
    if salt is None:
        salt = os.urandom(16)
    key = hashlib.pbkdf2_hmac('sha256', password.encode(), salt, 100000, dklen=32)
    iv = hashlib.pbkdf2_hmac('sha256', key, salt, 1, dklen=16)
    return key, iv, salt

def encrypt_message(plaintext: str, password: str) -> str:
    key, iv, salt = derive_key(password)
    cipher = Cipher(algorithms.AES(key), modes.GCM(iv), backend=default_backend())
    encryptor = cipher.encryptor()
    ciphertext = encryptor.update(plaintext.encode()) + encryptor.finalize()
    result = salt + iv + encryptor.tag + ciphertext
    return base64.b64encode(result).decode()

def decrypt_message(encrypted_b64: str, password: str) -> str:
    data = base64.b64decode(encrypted_b64)
    salt, iv, tag, ciphertext = data[:16], data[16:32], data[32:48], data[48:]
    key, _, _ = derive_key(password, salt)
    cipher = Cipher(algorithms.AES(key), modes.GCM(iv, tag), backend=default_backend())
    decryptor = cipher.decryptor()
    plaintext = decryptor.update(ciphertext) + decryptor.finalize()
    return plaintext.decode()

# ========== TON TRANSPORT ==========
def send_ton_message(recipient: str, encrypted_msg: str, amount_nano: int = 10000000) -> Dict:
    """
    Send a TON transfer with the encrypted message as a comment.
    This requires a wallet with private key – for demo we only simulate.
    Real implementation would use tonsdk to sign and send.
    """
    print(f"\n[✉️] Sending encrypted message to {recipient[:10]}...")
    print(f"     Encrypted payload (first 80 chars): {encrypted_msg[:80]}...")
    # In a real scenario, you would construct and send a TON transaction using tonsdk.
    # For Pydroid/Termux, we simulate the send.
    print("⚠️ Simulation only – real send requires tonsdk and your wallet's mnemonic.")
    print("   To send real messages, install tonsdk and uncomment the signing code.\n")
    return {"simulated": True, "comment": encrypted_msg}

def fetch_incoming_messages(address: str, limit: int = 10) -> List[Dict]:
    """Fetch recent transactions and extract encrypted comments."""
    params = {"address": address, "limit": limit, "archival": False}
    try:
        resp = requests.get(TON_API + "getTransactions", params=params, headers=HEADERS, timeout=15)
        resp.raise_for_status()
        data = resp.json()
        if not data.get("ok"):
            print(f"API error: {data.get('error')}")
            return []
        messages = []
        for tx in data.get("result", []):
            # Extract comment from in_msg (simplified – real comment is in message body)
            # For this demo, we assume the comment is stored as plain text in a specific field.
            # TON Center does not directly expose comments; we need to decode message bodies.
            # As a workaround, we show the transaction hash and let user manually check.
            # A full implementation would parse the message body using tonsdk.
            msg_hash = tx.get("transaction_id", {}).get("hash")
            messages.append({"hash": msg_hash, "comment": None, "raw_tx": tx})
        return messages
    except Exception as e:
        print(f"Failed to fetch messages: {e}")
        return []

# ========== CLI INTERFACE ==========
def main():
    print("\n" + "="*60)
    print("   MONTIDROID SIGNAL TOKYO – ENCRYPTED TON MESSENGER")
    print("="*60)
    print(f"Sender wallet (simulated): {SENDER_WALLET}")
    print(f"Recipient wallet: {RECIPIENT_WALLET}\n")

    while True:
        print("\n1. Encrypt & send a message")
        print("2. Fetch & decrypt recent messages (for given wallet)")
        print("3. Change recipient wallet")
        print("4. Exit")
        choice = input("Select: ").strip()

        if choice == "1":
            plain = input("Message to send: ").strip()
            if not plain:
                continue
            # Use a shared secret – in real use, derive from recipient's public key
            shared_secret = input("Shared secret (password) for encryption: ").strip()
            if not shared_secret:
                print("Shared secret required.")
                continue
            encrypted = encrypt_message(plain, shared_secret)
            send_ton_message(RECIPIENT_WALLET, encrypted)

        elif choice == "2":
            addr = input(f"Wallet address (default {SENDER_WALLET}): ").strip()
            if not addr:
                addr = SENDER_WALLET
            secret = input("Shared secret to decrypt messages: ").strip()
            if not secret:
                print("Shared secret required.")
                continue
            print(f"Fetching transactions for {addr[:10]}...")
            txs = fetch_incoming_messages(addr, limit=5)
            if not txs:
                print("No transactions or error.")
                continue
            print("\nRecent transactions (hashes only – full comment extraction requires tonsdk):")
            for tx in txs:
                print(f"  - {tx['hash']}")
            print("\nTo fully retrieve encrypted comments, you need to:")
            print("  1. Install tonsdk: pip install tonsdk")
            print("  2. Use tonsdk to decode message bodies and extract the comment.")
            print("  3. Then decrypt with the shared secret.")
            # Here we could simulate a known encrypted comment for testing.
            # For demonstration, we'll let the user paste an encrypted comment manually.
            enc_comment = input("\nPaste an encrypted message (b64) to decrypt (optional): ").strip()
            if enc_comment:
                try:
                    decrypted = decrypt_message(enc_comment, secret)
                    print(f"✅ Decrypted: {decrypted}")
                except Exception as e:
                    print(f"Decryption failed: {e}")

        elif choice == "3":
            new_recipient = input("New recipient wallet (EQ/UQ...): ").strip()
            if new_recipient.startswith(("EQ", "UQ")):
                global RECIPIENT_WALLET
                RECIPIENT_WALLET = new_recipient
                print(f"Recipient updated to {RECIPIENT_WALLET}")
            else:
                print("Invalid format.")

        elif choice == "4":
            print("Signal Tokyo – connection closed. Stay sovereign.")
            break
        else:
            print("Invalid choice.")

if __name__ == "__main__":
    main()
