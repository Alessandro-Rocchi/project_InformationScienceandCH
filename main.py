import spacy
from nltk import FreqDist

def main():
    f = open("data/dylan dog (fumetto)_wikipedia.txt", "r")
    orig_text = f.read()
    nlp = spacy.load("it_core_news_sm")
    doc = nlp(orig_text)
    pers = FreqDist([(X.text, X.label_) for X in doc.ents if X.label_ in ['PER']])
    frpep = pers.most_common(20)
    print(frpep)
    
if __name__ == "__main__":
    main()
