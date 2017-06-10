defmodule PushRequest do
	def to_xml(_push_request, message_id) do
		"<xml><message id='#{message_id}'>message</message></xml>"
	end
end