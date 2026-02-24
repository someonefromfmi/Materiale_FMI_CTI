CIPHERTEXTS = [
    "1C9FEA932083E9C9E33BC004E7979E",
    "1C9FED8F3195EBC3F53EC41AEC9E94",
    "1C9FF189318BEBC3E93BC311E4879E",
    "169EF98F3595EFDEEE39D901F99381",
    "1682ED982283E9DFF238C418E28694",
    "169EFB94228FFFD9FA36C407FF9B8E",
    "1299EC9E318AF7CDF53FC201F89E94"
]

DICTIONARY = open('wordlist.txt').read().split()

def xor_bytes(cuvant_criptat_hex_sau_bytes, key_bytes):
    # daca este hex string il convertim in bytes
    if isinstance(cuvant_criptat_hex_sau_bytes, str):
        cuvant_criptat_bytes = bytes.fromhex(cuvant_criptat_hex_sau_bytes)
    else:
        cuvant_criptat_bytes = cuvant_criptat_hex_sau_bytes
    # intoarce un nou sir de bytes rezultat din xor
    return bytes(a ^ b for a, b in zip(cuvant_criptat_bytes, key_bytes))

for word in DICTIONARY:
    # convertim cuvantul in octeti pentru xor
    word_bytes = word.encode()
    # calculam cheia potentiala facand xor intre primul cuvant criptat si cuvantul curent
    potential_key = xor_bytes(CIPHERTEXTS[0], word_bytes)

    # verificam daca aceasta cheie functioneaza pentru toate celelalte cuvinte criptate
    is_valid_key = True
    for cuvant_criptat in CIPHERTEXTS[1:]:
        # decriptam cuvantul criptat curent folosind cheia potentiala
        cuvant_decriptat_bytes = xor_bytes(cuvant_criptat, potential_key)
        try:
            # verificam daca rezultatul este un cuvant valid in dictionar
            if cuvant_decriptat_bytes.decode() not in DICTIONARY:
                is_valid_key = False
                break
        except:
            # daca nu se poate decoda ca ascii, cheia nu este valida
            is_valid_key = False
            break

    if is_valid_key:
        print("Key (hex):", potential_key.hex())
        # decriptam fiecare cuvant criptat cu cheia gasita
        for i, cuvant_criptat in enumerate(CIPHERTEXTS):
            plaintext = xor_bytes(cuvant_criptat, potential_key).decode()
            print(f"Plaintext {i+1}: {plaintext}")
        break

