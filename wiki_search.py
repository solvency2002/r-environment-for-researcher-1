import requests

QUERY = 'insource:"KOKIA" -linksto:KOKIA'
S = requests.Session()
S.headers.update({"User-Agent": "WikiSearchBot/1.0 (https://example.com/bot; bot@example.com)"})
URL = "https://ja.wikipedia.org/w/api.php"

params = {
    "action": "query",
    "list": "search",
    "srsearch": QUERY,
    "srlimit": "max",
    "format": "json",
}

titles = []
sroffset = 0
while True:
    params["sroffset"] = sroffset
    data = S.get(URL, params=params).json()
    hits = data["query"]["search"]
    titles.extend([h["title"] for h in hits])
    if "continue" not in data:
        break
    sroffset = data["continue"]["sroffset"]

print("count:", len(titles))
print(titles[:30])
