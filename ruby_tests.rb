# Tests for ruby_server.rb
#
# gem install minitest
# gem install rest-client
# gem install json
#
# Run with `ruby ruby_tests.rb`
#

require 'minitest/autorun'
require 'rest_client'
require 'json'

# Some constants
BASE_URL = "http://localhost:4567"
N_QUERY_PATH = "/n-query"
N_NEW_PATH = "/n-new"
N_NEW_KEY = "n-new"
RESULT_VALUE_KEY = "result-value"

class RubyTests < Minitest::Test

    #########################
    #
    # GET n-query endpoint tests
    #
    # Because this endpoint takes no parameters (because of how the reqs are defined), we cannot exercise
    # any -ve test cases. The most we can do is test the +ve cases.


    # Basic +ve test
    # Only asserts the resp code
    # def test_get_n_query_basic
    #     code, body = send_n_query_get
    #     assert_equal(200, code, "Valid GET request to n-query endpoint did not receive a 200 response code")
    # end

    # # More thorough +ve test
    # # Asserts the full body
    # # Note : because of how the problem has been defined, the correct value returned in RESULT_VALUE_KEY cannot be determined
    # # by these tests. Only the server knows what it should be. So the most that we can do is assert that it conforms to the schema. 
    # def test_get_n_query_thorough
    #     code, body = send_n_query_get
    #     assert_equal(200, code, "Valid GET request to n-query endpoint did not receive a 200 response code")
    #     # Assert the body is valid
    #     assert(body, "Valid GET request to n-query endpoint did not receive a response body")
    #     assert(body.is_a?(Hash), "Valid GET request to n-query endpoint did not receive a JSON object response body")

    #     expected_keys = [RESULT_VALUE_KEY]
    #     assert_equal(expected_keys, body.keys, "n-query endpoint response did not contain only the expected keys #{expected_keys}")

    #     value = body[RESULT_VALUE_KEY]
    #     assert(value, "n-query endpoint response did not contain a valid #{RESULT_VALUE_KEY} value")
    #     assert(value.is_a?(Numeric), "n-query endpoint response did not contain a nummeric #{RESULT_VALUE_KEY} value")
    # end


    #########################
    #
    # POST n-new endpoint tests
    # 
    # POST body should be JSON, with one key ('n-new'), whose value is numeric, e.g. "{'n-new': 5}"

    # Basic +ve test
    # Only asserts the resp code
    def test_post_n_new_int
        hash = {"n-new" => 5}
        send_post_assert_valid_n_new_response(hash)
    end

    def test_post_n_new_int_zero
        hash = {"n-new" => 0}
        send_post_assert_valid_n_new_response(hash)
    end

    def test_post_n_new_float
        hash = {"n-new" => 54321.9876}
        send_post_assert_valid_n_new_response(hash)
    end

    def test_post_n_new_float_negative
        hash = {"n-new" => -432154321.9876}
        send_post_assert_valid_n_new_response(hash)
    end

    # Some languages allow _ as a thousands-separator
    def test_post_n_new_case_numerical_underscore
        hash = {"n-new" => 34_000} # Ruby interprets this as a number, not a string
        send_post_assert_valid_n_new_response(hash)
    end
    
    # The straightforward POST n-new tests can all use this to send the +ve request & assert the response
    def send_post_assert_valid_n_new_response(hash)
        code, body = send_n_new_post(hash)
        assert_equal(200, code, "Valid POST request to n-new endpoint did not receive a 200 response code")
        assert_nil(body, "Valid POST request to n-new endpoint did not receive an empty body")
    end
    
    # Some -ve cases
    
    def test_post_n_new_string
        hash = {"n-new" => "one"}
        send_post_assert_invalid_n_new_response(hash)
    end
    
    
    def test_post_n_new_numeric_string
        hash = {"n-new" => "4"}
        send_post_assert_invalid_n_new_response(hash)
    end
    
    def test_post_n_new_boolean
        hash = {"n-new" => true}
        send_post_assert_invalid_n_new_response(hash)
    end
    
    def test_post_n_new_nil
        hash = {"n-new" => nil}
        send_post_assert_invalid_n_new_response(hash)
    end
    
    def test_post_n_new_no_body
        hash = nil
        send_post_assert_invalid_n_new_response(hash)
    end
        
    def test_post_n_new_empty_body
        hash = {}
        send_post_assert_invalid_n_new_response(hash)
    end
    
    def test_post_n_new_no_n_new
        hash = {"n-query" => 4}
        send_post_assert_invalid_n_new_response(hash)
    end
    
    def test_post_n_new_extra_variable
        hash = {"n-new" => 3, "n-query" => 4}
        send_post_assert_invalid_n_new_response(hash)
    end

    def test_post_n_new_case_sensitive
        hash = {"N-NEW" => 23}
        send_post_assert_invalid_n_new_response(hash)
    end
    
    def test_post_n_new_case_underscore
        hash = {"n_new" => 34}
        send_post_assert_invalid_n_new_response(hash)
    end

    # Some languages allow _ as a thousands-separator
    def test_post_n_new_case_numerical_underscore_string
        hash = {"n-new" => "34_000"}
        send_post_assert_invalid_n_new_response(hash)
    end

    # The POST n-new tests can all use this to send the -ve request & assert the response
    def send_post_assert_invalid_n_new_response(hash)
        code, body = send_n_new_post(hash)
        assert_equal(400, code, "Invalid POST request to n-new endpoint did not receive a 400 response code")
        assert_nil(body, "Inalid POST request to n-new endpoint did not receive an empty body")
    end

    # More complicated -ve tests

    def test_post_n_new_duplicate_key
        # Need to do this in a more 'raw' fashion
        json = "'n-new':4,'n-new':4"
        
        url = BASE_URL + N_NEW_PATH
        client = RestClient::Resource.new(url)
        resp = post_request(client, json, is_already_json = true)
        code = resp.code
        body = get_response_body(resp)
        
        assert_equal(400, code, "Invalid POST request to n-new endpoint did not receive a 400 response code")
        assert_nil(body, "Inalid POST request to n-new endpoint did not receive an empty body")
    end


    def test_post_n_new_xml
        # Need to do this in a more 'raw' fashion
        xml = "<n-new>4</n-new>"
        
        url = BASE_URL + N_NEW_PATH
        client = RestClient::Resource.new(url)
        resp = post_request(client, xml, is_already_json = true)
        code = resp.code
        body = get_response_body(resp)
        
        assert_equal(400, code, "Invalid POST request to n-new endpoint did not receive a 400 response code")
        assert_nil(body, "Inalid POST request to n-new endpoint did not receive an empty body")
    end


    #########################################################################
    #
    # Helper methods
    #
    #########################################################################

    # Method to perform a GET request. Requires the RESTClient Resource client.
    # Returns a RESTClient::Response object
    def get_request(client)
        begin
            client.get
        rescue OpenSSL::SSL::SSLError => e
            raise "SSLError occurred when calling REST service; #{e}"
        rescue RestClient::Exception => e # if the request failed, RestClient will throw an error. We want to retrieve that error and the response within
            # puts "RestClient::Exception hit when calling REST service"
            # puts e
            # puts e.response
            return e.response
        rescue => e
            raise "Unexpected error occurred when calling REST service; #{e}"
        end
    end

    # Method to perform a GET request. Requires the RESTClient Resource client and a hash for the request body.
    # Returns a RESTClient::Response object
    def post_request(client, post_body_hash, is_already_json = false)
        headers = {:content_type => "application/json"}

        begin
            if is_already_json
                # post_body_hash is already in JSON form
                client.post(post_body_hash, headers)
            else
                client.post(JSON.generate(post_body_hash), headers)
            end
        rescue OpenSSL::SSL::SSLError => e
            raise "SSLError occurred when calling REST service; #{e}"
        rescue RestClient::Exception => e # if the request failed, RestClient will throw an error. We want to retrieve that error and the response within
            # puts "RestClient::Exception hit when calling REST service"
            # puts e
            # puts e.response
            return e.response
        rescue => e
            raise "Unexpected error occurred when calling REST service; #{e}"
        end
    end

    # Converts the body of the response object from JSON to Ruby, and sets the defaults for the main hash and all sub-hashes
    def get_response_body(response)
        raise "REST response was nil" if response == nil
        raise "REST response had no attached body" if response.body == nil
        return nil if response.body == ""

        begin
            body = JSON.parse(response.body)
        rescue JSON::ParserError => e
            puts "rescued : ParserError"
            puts e
            body = response.body
        end
        body
    end

    # Makes a GET request to the n-query endpoint.
    # Retuns the response code & body (converted from JSON)
    def send_n_query_get
        url = BASE_URL + N_QUERY_PATH
        client = RestClient::Resource.new(url)
        resp = get_request(client)
        code = resp.code
        body = get_response_body(resp)
        return code, body
    end

    # Makes a POST request to the n-new endpoint.
    # Retuns the response code & body (converted from JSON)
    def send_n_new_post(body)

        url = BASE_URL + N_NEW_PATH
        client = RestClient::Resource.new(url)
        resp = post_request(client, body)
        code = resp.code
        body = get_response_body(resp)
        return code, body
    end



end
