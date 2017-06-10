defmodule Annotator.HTML do
	def annotate(word) do
		"""
		<div class="ann sann iann sann" onmouseover="sP(this, event)" style="">
			<div class="py">#{word["piny"]}</div>
			<div class="zh">#{word["simp"]}</div>
		</div>
		"""
	end
end