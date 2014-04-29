require 'uri'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  attr_accessor :params
  def initialize(req, route_params = {})
    @params = parse_www_encoded_form(req)
  end

  def [](key)
    self.params[key]
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    param_hash = {}


    body = www_encoded_form.body
    param_hash.merge!(parse_url(body)) unless body.nil?

    query_string = www_encoded_form.query_string
    param_hash.merge!(parse_url(query_string)) unless query_string.nil?

    param_hash
  end

  def parse_url(values)
    key_vals = URI.decode_www_form(values)
    param_hash = {}


    key_vals.each do |pair|
      key = pair[0]
      val = pair[1]
      key_path = parse_key(key)

      if key_path.length == 1
        param_hash[key] = val
      else
        current_hash = param_hash
        key_path.each_with_index do |inner_key, i|
          inner_hash = current_hash[inner_key] ||= {}
          if (i != key_path.length-1)
            current_hash[inner_key] = inner_hash
            current_hash = inner_hash
          else
            current_hash[inner_key] = val
          end
        end
      end
    end

    param_hash
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end
end
