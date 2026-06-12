from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives import hashes
import secrets

# Generate a NEW key (never seen before)
new_priv = ec.generate_private_key(ec.SECP256K1())
new_pub = new_priv.public_key()
# Print only the public address (safe to share)
pub_bytes = new_pub.public_bytes(encoding=serialization.Encoding.X962,
                                 format=serialization.PublicFormat.UncompressedPoint)
# Compute Ethereum address (last 20 bytes of keccak256)
# ... (standard method)
print("New public address (share publicly):", eth_address)
# Keep the private key offline, split it immediately
