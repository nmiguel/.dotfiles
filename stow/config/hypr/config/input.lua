hl.config({
	input = {
		numlock_by_default = true,
		kb_layout = "us",
		kb_options = "compose:caps",
		-- kb_variant =,
		-- kb_model =,
		-- kb_rules =,

		follow_mouse = 1,

		sensitivity = 0.2, -- -1.0 - 1.0, 0 means no modification.
		repeat_rate = 50,
		repeat_delay = 200,

		-- force_no_accel = 1,
		accel_profile = "flat",
	},
})

hl.config({
	cursor = {
		no_hardware_cursors = true,
	},
})
