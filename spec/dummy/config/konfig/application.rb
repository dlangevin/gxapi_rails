#
# konfig do
#   emails do
#     default_from "foo@bar.com"
#     delay(:sent_at){ Time.now }
#   end
# end
# 
# konfig.emails.headers = {"Return-path" => "developers@lifebooker.com"}

konfig do
  rails_app do
    from_app "a"
    overridden_value "a"
  end
end