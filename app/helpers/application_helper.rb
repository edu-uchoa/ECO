require 'uri'

module ApplicationHelper
	# Renders a safe "back" link that navigates to the HTTP referer when present
	# and belongs to the same host, otherwise falls back to the provided path
	#
	# Usage:
	#   <%= back_link "Back", class: "btn" %>
	#   <%= back_link "Cancel", fallback: dashboard_path, class: "text-sm" %>
	def back_link(name = "Back", fallback: root_path, **options)
		referer = request.referer || request.referrer

		href = fallback
		if referer.present?
			begin
				uri = URI.parse(referer.to_s)
				# only allow referer from same host to avoid open redirect
				href = referer if uri.host == request.host
			rescue URI::Error
				href = fallback
			end
		end

		link_to name, href, **options
	end

	# Simple JS back button (client-side history.back()). Useful when you don't
	# want to rely on the referer header (works even with Turbo/Hotwire).
	# Usage:
	#   <%= js_back_button "Go back", class: "btn" %>
	def js_back_button(label = "Go back", **options)
		options[:type] = "button"
		options[:onclick] = "history.back();"
		tag.button label, **options
	end
end
