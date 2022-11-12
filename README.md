# KJVSearch

[![iOS starter workflow](https://github.com/paulobfsilva/KJVSearch/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/paulobfsilva/KJVSearch/actions/workflows/CI.yml)

 Semantic Search app for KJV Bible

## Use Cases

### Load Feed From Remote Use Case

#### Data:
- URL, query text

#### Primary Course (happy path):
1. Execute "Load Search Items" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates search items from valid data.
5. System delivers feed items.

#### Invalid data - error course (sad path):
1. System delivers error.

#### No connectivity - error course (sad path):
1. System delivers connectivity error.

### Load Search From Cache (Fallback) Use Case

#### Data:
- Max age (30 days)

#### Primary course:
1. Execute "Retrieve Search Items" command with above data. 
2. System fetches search data from cache.
3. System validates cache is less than 30 days old.
4. System creates search items from cached data.
5. System delivers search items.

#### Retrieval error course (sad path):
1. System delivers error.

#### Expired cache course (sad path):
1. System delivers no search items.

#### Empty cache course (sad path):
1. System delivers no search items.

### Cache Search Results Use Case

#### Data:
- Search items

#### Primary course (happy path):
1. Execute "Save search result items" command with above data.
2. System deletes old cache data.
3. System encodes search items.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message. 

#### Deleting error course (sad path):
1. System delivers error.

#### Saving error course (sad path):
1. System delivers error.


### Validate Search Results Use Case

#### Primary course:
1. Execute "Validate Cache" command with above data. 
2. System fetches search data from cache.
3. System validates cache is less than 30 days old.

#### Retrieval error course (sad path):
1. System deletes cache.

#### Expired cache course (sad path):
1. System deletes cache.

### System requirements for cache implementation (basis for test-driving)

#### Retrieve
- Empty cache returns empty
- Empty cache twice returns empty (no side-effects)
- Non-empty cache returns data
- Non-empty cache twice returns data (no side-effects)
- Error (if applicable, e.g., invalid data)
- Error twice returns same error (if applicable, e.g., invalid data)

#### Insert
- To empty cache stores data
- To non-empty cache overrides previous data with new data
- Error (if applicable, e.g., no write permission)

#### Delete
- Empty cache does nothing (cache stays empty and does not fail)
- Non-empty cache leaves cache empty
- Error (if applicable, e.g., no delete permission)

#### Side-effects must run serially to avoid race-conditions

## UX goals for the Search UI Experience

#### Load search results automatically when the search button is tapped
#### Allow customer to automatically retrive more results (scroll down to retrieve more)
#### Show a loading indicator while loading the search results
#### Render all loaded search results (scripture, distance, text)
