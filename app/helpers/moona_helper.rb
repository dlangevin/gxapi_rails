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
  def moona_experiment_js(*args)
    # extract options
    opts = args.last.is_a?(Hash) ? args.pop : {}
    # default 
    ivar_name = args.first || :variant

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
      ret += "\n"
      # set domain name if present
      if opts[:domain]
        domain_call = javascript_tag{
          "cxApi.setDomainName('#{escape_javascript(opts[:domain])}');".html_safe
        }
        ret += domain_call.html_safe
        ret += "\n"
      end
    end
    
    @moona_experiment_called = true

    ret += javascript_tag{
      "cxApi.setChosenVariation(
        #{variant.value.index}, 
        '#{escape_javascript(variant.value.experiment_id)}'
      );".html_safe
    }
    ret.html_safe
  end
end