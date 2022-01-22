import csv
from typing import Dict

from eth_utils import is_address, to_canonical_address, to_bytes


def load_airdrop_file(airdrop_file: str) -> Dict[bytes, int]:
    with open(airdrop_file) as file:
        reader = csv.reader(file)
        address_value_pairs = list(reader)
        # print('address_value_pairs',address_value_pairs)

    # validate_address_value_pairs(address_value_pairs)
    return {
        to_canonical_address(address)+int(value).to_bytes(32, "big"): int(value)
        for address, value in address_value_pairs
    }


def validate_address_value_pairs(address_value_pairs):
    addresses = set()
    for address_value_pair in address_value_pairs:
        if len(address_value_pair) != 2:
            raise ValueError(
                f"Expected two values per line, but got {len(address_value_pairs)}"
            )

        address, value = address_value_pair
        if not is_address(address):
            raise ValueError(
                f"Expected checksummed hex address, but got {address}")

        canonical_address = to_canonical_address(address)
        if canonical_address in addresses:
            raise ValueError(f"Got address {address} multiple times")
        addresses.add(canonical_address)


if __name__ == "__main__":
    data = load_airdrop_file(
        "/Users/shouhewu/devWorkspace/defiWorkspace/nft1155_merkle_aidrdrop/data/airdrop.csv")
    print(data)
