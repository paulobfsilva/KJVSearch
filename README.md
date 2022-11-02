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
3. System creates search items from cached data.
4. System delivers search items.

#### Error course (sad path):
1. System delivers error.

#### Expired cache course (sad path):
1. System deletes cache.
2. System delivers no search items.

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
