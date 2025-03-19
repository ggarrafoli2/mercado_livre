import requests
import pandas as pd
from pandas import json_normalize

prods = ['chromecast', 'apple tv', 'alexa', 'google home']

def get_chrom(prod):
    """
    Retorna uma lista de chromecast do Mercado Livre.
    
    Args:
    None
    
    Returns:
    Uma lista de chrom.
    """
    url = "https://api.mercadolibre.com/sites/MLA/search?q=%s&limit=50#json" % prod
    print(url)
    
    response = requests.get(url)
    
    if response.status_code == 200:
        return response.json()["results"]
    else:
        raise Exception(response.status_code)

if __name__ == "__main__":
    df_ = pd.DataFrame()

    for nomes in prods:
        produtos_ = get_chrom(nomes)
        
        for produto in produtos_:
            df = pd.DataFrame([produto])
            df_ = pd.concat([df_, df])

    df_.to_csv("Servicio_Publico.csv", sep=",", index=False)
