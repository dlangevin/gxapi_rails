module MoonaHelper

  # get the version for a given variant
  # @return [String]
  def moona_variant_name(ivar_name = :variant)
    # if we have params[ivar], we just use it
    return params[ivar_name] if params[ivar_name].present?
    return "default" unless variant = instance_variable_get("@#{ivar_name}")
    return variant.value.try(:name) || "default"
  end

  # get the HTMl to load script from Google Ananlytics
  # and setChosenVariation to tell it which one we served
  def moona_experiment_js(ivar_name = :variant)
    # make sure we have our variant
    return "" unless variant = instance_variable_get("@#{ivar_name}")
    # and a valid experiment id
    return "" unless variant.value.experiment_id.present?
    # our return value
    ret = ""
    # first time we call this, we add the script
    unless @moona_experiment_called == true
      ret += javascript_include_tag(
        "https://www.google-analytics.com/cx/api.js"
      )
    end
    
    @moona_experiment_called = true

    ret += javascript_tag{
      "cxApi.setChosenVariation(
        #{variant.value.index}, 
        '#{escape_javascript(variant.value.experiment_id)}'
      );"
    }
    ret.html_safe
  end
end