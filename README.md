# KR-on-the-Web
> This is a course project from Knowledge Representation on the Web, Vrije Universiteit Amsterdam.
## 1. Link to the project 
https://github.com/MikeyQiu/KR-on-the-Web/
## 2. Project details: What is the project’s goal? Why is it important or interesting? 
Articles often have multiple authors, for which each name is mentioned at the beginning of the article. However, the role of each other is rarely mentioned in articles, preventing researchers and readers to acknowledge each author's work. We aim to discover contributionship based on [CRediT](https://casrai.org/credit/) instead of authorship from papers, by meirging linked data from the Microsoft Academic Knowledge Graph(MAKG), meta data, commitmentss from Github and raw information from text.
## 3. Data Resource
We obtained our data through the api of [Paper with Code](https://paperswithcode.com/), where both Github repository and Paper's PDF links are accessiable.
## 4. Get Started
### 4.1 Data
We prepared our data in both relational sql database and rdf triples in turtle format, which are located in data directory.
### 4.2 Preprocessing
This part is implemented by the scripts in Jasper's directory. Afterwards we selected roughly 3000 papers and 8000 authors for evaluation.
### 4.3 Contributionship Discovery
We focused ourselves on 5 out of 14 contribution roles from the CRediT Methodology. 
#### Software

- This part is impemented by [git_scraping.ipynb](https://github.com/MikeyQiu/KR-on-the-Web/blob/master/git_scraping.ipynb)
- Based on the assumption that github user name and author name are likely to be same, we link author name with github repository contributors

#### Supervision, etc.

- This part is impemented by [textmining_final-Copy1.ipynb](https://github.com/MikeyQiu/KR-on-the-Web/blob/master/textmining_final-Copy1.ipynb)
- We derive author related information from the raw data of the PDF link, derive author contribution roles like Resource and Supervision comparing with the meta data from MAKG.

### 4.4 Output
After extraction, roles are serialized in turtle format and uploaded to linked database of [triply.com](https://triplydb.com/jasper-grannetia/KRW)

### 5 Evaluation
We made a number of SPARQL query to gain some insight from data. Also we used the GraphDB and highcharts.js for query visualization.
