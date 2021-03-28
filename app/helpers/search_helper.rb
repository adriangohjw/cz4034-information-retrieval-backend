module SearchHelper

  def self.concat_hash_into_array(*hashes)
    array_result = Array.new

    hashes.each do |hash|
      array_result << hash if !hash.blank?
    end
    
    return array_result
  end

  def self.querystring_to_hash(param_name: nil, querystring:)
    return nil if querystring.blank?
    if param_name.blank?
      return {
        query_string: {
          query: "#{querystring}"
        }
      }
    else
      return {
        query_string: {
          query: "#{param_name}: (#{querystring})"
        }
      }
    end
  end

end