# fix for: AlphaFlag value is not 1 or 2 is -255

import os

def read() -> str:
    files: list[str] = os.listdir("./")

    for fileName in files:
        if fileName.endswith(".paa"):
            with open("./" + "\\" + fileName, "r+b") as file:
                return file


def main() -> None:
    flag: str = "0400000001000000"
    file: str = read()

    file.seek(2, 0)

    for _ in range(5):
        if file.read(8) == b'GGATGALF':
            file.write(bytes.fromhex(flag))
            break


if __name__ == "__main__":
    main()
