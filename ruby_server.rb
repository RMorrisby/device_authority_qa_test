# Simple Ruby webserver
# Built using Ruby 3
# 
# You will need these gems :
# gem install sinatra
# gem install thin
# gem install file-tail
#
# Start with `ruby ruby_server.rb`
#
# Call with `curl http://localhost:4567/n-query`
# and `curl -d "{\"n-new\": 5}" -H "Content-Type: application/json" -X POST http://localhost:4567/n-new`


require 'sinatra'
require 'json'
require 'file-tail'

N_QUERY_FILE = "n_query_file.txt"
N_NEW_KEY = "n-new"
RESULT_VALUE_KEY = "result-value"

# Retrieve the stored n-query value
def retrieve_n_query_value
    # Read from local file
    if File.exist?(N_QUERY_FILE)
        # This will read only the last two lines in the file, returning the last value, minus any whitespace
        # This allows for the last line in the file to be only whitespace
        File::Tail::Logfile.open(N_QUERY_FILE, :break_if_eof => true) do |log|
            s = ""
            begin
                log.backward(2).tail { |line| s += line }
            rescue File::Tail::BreakException
                # do nothing, this is expected
            ensure
                return nil if s.empty?
                
                s.strip!
                return s.split("\n")[-1].strip
            end
        end
    else
        # return nil of the file doesn't exist
        nil
    end
end

# Stores the received value
# Append the value to the N_QUERY_FILE file 
def store_n_new_value(v)
    init_n_query_file unless File.exist?(N_QUERY_FILE)  

    File.open(N_QUERY_FILE, "a") do |f|
        f.puts v
    end
end

# Create the N_QUERY_FILE file (as an empty file)
def init_n_query_file
    File.new(N_QUERY_FILE, "w") # write nothing to the file
end

# Is the received n-new payload valid?
# Takes a hash of the JSON received by the request
# Expects to only have one key ("n-new") whose value is numeric
def valid_n_new_payload?(json)
    return false if json.nil? || json.empty?
    return false if json.keys.size > 1
    return false unless json.keys.include?(N_NEW_KEY)

    v = json[N_NEW_KEY]
    return false if v.nil?
    return false unless v.is_a?(Numeric)
   
    true # we've not found any faults, so return true
end


def extract_n_new_from_payload(json)
    json[N_NEW_KEY]
end

# POST body should be JSON, with one key ('n-new'), whose value is numeric, e.g. "{'n-new': 5}"
# If invalid, return a 400 and no error message 
# (the reqs say 'No response body', which extends to errors, which is bad design, but that's what's been requested)
post '/n-new' do
    request.body.rewind
    body = request.body.read

    # If the payload isn't valid JSON, return a 400
    json = nil
    begin
        json = JSON.parse(body)
    rescue
        puts "Received non-JSON payload : #{body.inspect}"
        return [400] # return a 400 & no body
    end

    if valid_n_new_payload?(json)
        store_n_new_value(extract_n_new_from_payload(json))
        [200] # return a 200 & no body
    else
        [400] # return a 400 & no body
    end
end

# Note : the task does not make it clear if it wants a variable to be supplied in the request,
# e.g. GET /n-query?v=2
# or if this endpoint takes no variables or parameters, and the request will ALWAYS return a value corresponding 
# to the current / most recent n-query value stored by the system
# e.g. GET /n-query
#
# These requirements need to be clarified
#
# For now, we assume that the request takes no variables or other parameters, because it states
# `‘n-query’ value is retrieved from external location/file (e.g. ‘2’)`
# which strongly implies that the n-query value is not passed in via the URL or request
get '/n-query' do
    # Retrieve current n-query value from DB/storage
    v = retrieve_n_query_value # this will be a string
    
    # TODO mabye don't return a 200 if the value doesn't exist? 
    # We don't know enough context; the requirements are not well-enough defined
    # Is the value not existing a valid state? Is the user supposed to call POST /n-new first, to supply a value?
    v = 0 if v.nil? || v.empty?

    # If the value is not a number, return a 500
    # Since (in this current implementation) we control what the value is, it should only ever be a number
    # Therefore, if it is not, we have done something wrong
    if v.to_s =~ /[^0-9.,_]/
        error = {}
        error["error"] = "Retrieved n-query value was not a number; something has gone wrong"
        return [500, error.to_json]
    end

    # Convert to float if it looks like a float, otherwise convert to int
    if v.is_a?(String) && v.include?(".")
        v = v.to_f 
    else
        v = v.to_i
    end
    
    h = {}
    h[RESULT_VALUE_KEY] = v ** 2 # square the value

    # Return 200 & the result-value JSON body
    [200, h.to_json]
  end
  
  
