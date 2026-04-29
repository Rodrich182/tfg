#!/usr/bin/env python3


import argparse
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--bin", required=True, dest="bin_path")
    parser.add_argument("--out-dir", required=True)
    parser.add_argument("--base-name", default="firmware")
    parser.add_argument("--depth", type=int, required=True)
    parser.add_argument("--word-width", type=int, default=32)
    parser.add_argument("--default-word", default="00000013")
    return parser.parse_args()


def chunk_bytes(data: bytes, word_bytes: int) -> list[bytes]:
    chunks: list[bytes] = []

    for offset in range(0, len(data), word_bytes):
        chunk = data[offset : offset + word_bytes]
        if len(chunk) < word_bytes:
            chunk = chunk + bytes(word_bytes - len(chunk))
        chunks.append(chunk)

    return chunks


def words_from_binary(data: bytes, word_bytes: int) -> list[int]:
    return [int.from_bytes(chunk, byteorder="little", signed=False) for chunk in chunk_bytes(data, word_bytes)]


def emit_mif(words: list[int], word_width: int) -> str:
    return "\n".join(f"{word:0{word_width}b}" for word in words) + "\n"


def emit_coe(words: list[int], hex_digits: int) -> str:
    lines = [
        "memory_initialization_radix=16;",
        "memory_initialization_vector=",
    ]

    for index, word in enumerate(words):
        terminator = ";" if index == len(words) - 1 else ","
        lines.append(f"{word:0{hex_digits}X}{terminator}")

    lines.append("")
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    bin_path = Path(args.bin_path).resolve()
    out_dir = Path(args.out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    if args.word_width % 8 != 0:
        raise SystemExit("word-width must be a multiple of 8 bits.")

    word_bytes = args.word_width // 8
    hex_digits = args.word_width // 4
    default_word = int(args.default_word, 16)

    data = bin_path.read_bytes()
    used_words = words_from_binary(data, word_bytes)

    if len(used_words) > args.depth:
        raise SystemExit(
            f"Binary requires {len(used_words)} words but ROM depth is only {args.depth} words."
        )

    padded_words = used_words + [default_word] * (args.depth - len(used_words))

    base = out_dir / args.base_name
    mif_path = base.with_suffix(".mif")
    coe_path = base.with_suffix(".coe")

    mif_path.write_text(emit_mif(padded_words, args.word_width), encoding="ascii")
    coe_path.write_text(emit_coe(padded_words, hex_digits), encoding="ascii")

    print(f"Generated: {mif_path}")
    print(f"Generated: {coe_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
