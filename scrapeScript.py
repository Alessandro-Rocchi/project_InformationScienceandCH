import wikipediaapi

wiki_it = wikipediaapi.Wikipedia(
    user_agent='InfoUmaProject/1.0 (alle200202@gmail.com)',
    language='it',
    extract_format=wikipediaapi.ExtractFormat.WIKI
)

nome_pagina = "Dylan Dog"
print(f"Scaricando la pagina '{nome_pagina}'...")
pagina = wiki_it.page(nome_pagina)

if pagina.exists():
    testo_completo = pagina.text
    
    # 2. Definisci il nome del file in cui salvare il testo
    nome_file = f"data/{nome_pagina.lower()}_wikipedia.txt"
    
    # 3. Salva il file sul disco
    # IMPORTANTE: usa encoding="utf-8" per gestire correttamente le lettere accentate (à, è, ì, ò, ù)
    with open(nome_file, "w", encoding="utf-8") as file:
        file.write(testo_completo)
        
    print(f"Successo! Il testo è stato salvato nel file: {nome_file}")

else:
    print("La pagina specificata non esiste.")