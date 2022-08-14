# Device Authority QA Test

## How to use

### Server

The class providing the server functionality for this exercise is `ruby_server.rb`. This will also

Works on Ruby version 3 (probably also woks on Ruby version 2.7). Some gems are needed :

```
gem install sinatra
gem install thin
gem install file-tail
```

Start the server in a terminal window with `ruby ruby_server.rb`

Example curl commands to its endpoints :

```
curl http://localhost:4567/n-query
curl -d "{\"n-new\": 5}" -H "Content-Type: application/json" -X POST http://localhost:4567/n-new
```

### Tests

All tests are contained within file `ruby_tests.rb`

Works on Ruby version 3 (probably also woks on Ruby version 2.7). Some gems are needed :

```
gem install sinatra
gem install thin
gem install file-tail
```

Start the server in a terminal window with `ruby ruby_server.rb`

Example curl commands to its endpoints :

```
curl http://localhost:4567/n-query
curl -d "{\"n-new\": 5}" -H "Content-Type: application/json" -X POST http://localhost:4567/n-new
```

## Notes

### Requirements

The requirements for the two requested endpoints are not fully defined.

For the `GET n-query` endpoint, it is not clear if it wants a variable to be supplied in the request, e.g. `GET /n-query?v=2`
or if this endpoint takes no variables or parameters, and the request will ALWAYS return a value corresponding
to the current / most recent n-query value stored by the system, e.g. `GET /n-query`

It states `One request parameter ‘n-query’ OR as part of RESTful URL` which doesn't make sense. Do we include a _query_ parameter, or a _path_ parameter, or neither? As written, `GET /n-query` with no body - and hence carrying no variables or parameters bar the fixed URL - is completely valid and meets these reqs.

For now, we assume that the request takes no variables or other parameters, because it states
`‘n-query’ value is retrieved from external location/file (e.g. ‘2’)`
which strongly implies that the n-query value is not passed in via the URL or request, but that it is a single value stored by the system.

It is also unclear what the relationship is between `n-new` and `n-query`. Is the `n-new` variable supplied in the POST is actually meant to be the same variable returned by the GET?
Currently they have two different names (`n-new` and `n-query`), so we currently treat them as two different variables.

### Refactoring

For a proper codebase, these two Ruby files would be refactored to have their helper methods & additional code moved into other classes & files, so that other classes could also use them. The scope of this test application & its tests is not defined, so for now this refacoring has not been done (because we don't know if we need it)
