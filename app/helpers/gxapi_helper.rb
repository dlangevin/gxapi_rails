
#
# View helper for Gxapi.
#
# @author [dlangevin]
#
module GxapiHelper

  #
  # Get the version for a given variant
  # @return [String]
  def gxapi_variant_name(ivar_name = :variant)
    # if we have params[ivar], we just use it
    return "default" unless variant = instance_variable_get("@#{ivar_name}")
    return variant.value.try(:name) || "default"
  end

  #
  # Get the variant if it exists and has an experiment_id
  #
  # @param  ivar_name [String] Name of the instance variable for the
  # variant
  #
  # @return [Gxapi::Ostruct, false] Variant if it exists, false otherwise
  def get_variant(ivar_name)
    # make sure we have our variant
    unless variant = instance_variable_get("@#{ivar_name}")
      Gxapi.logger.debug { "No variant found - #{ivar_name}" }
      return false
    end
    # and a valid experiment id
    unless variant.value.experiment_id.present?
      Gxapi.logger.debug { "No experiment_id found : #{variant.value} "}
      return false
    end
    return variant
  end

  #
  # Get the HTMl to load script from Google Ananlytics
  # and setChosenVariation to tell it which one we served
  #
  # @return [String] HTML
  def gxapi_experiment_js(*args)
    # extract options
    opts = args.last.is_a?(Hash) ? args.pop : {}
    # default
    ivar_name = args.first || :variant

    unless variant = self.get_variant(ivar_name)
      return ""
    end

    # our return value
    ret = ""
    # first time we call this, we add the script
    unless @gxapi_experiment_called == true
      ret += self.gxapi_source(opts)
      Gxapi.logger.debug {"Rendered Gxapi source"}
    end

    @gxapi_experiment_called = true

    ret += javascript_tag{
      "cxApi.setChosenVariation(
        #{variant.value.index},
        '#{escape_javascript(variant.value.experiment_id)}'
      );".html_safe
    }

    Gxapi.logger.debug { "#{ivar_name} is now #{variant.value.name}" }

    ret.html_safe
  end

  #
  # The Javascript tag for the Content experiment API
  #
  # @param [Hash] opts Hash of options
  #
  # @return [String] HTML for the tag
  def gxapi_source(opts)
    ret = javascript_include_tag(
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
    ret
  end

end