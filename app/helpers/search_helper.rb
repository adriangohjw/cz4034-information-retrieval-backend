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

  def self.array_param_to_hash(param_name:, array_param:)
    return Array.new if array_param.blank?

    hash_result = { 
      bool: {
        should: [],
      }
    }

    array_param.each do |item|
      hash_result[:bool][:should].append(
        {
          match_phrase: {
            "#{param_name}": item
          }
        }
     )
    end

    return hash_result
  end
  
end