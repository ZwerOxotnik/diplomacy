-- https://mods.factorio.com/mod/diplomacy/discussion/5dea3f4e8b3bf8000d9ac387

-- Called when someone/something changed a diplomacy relationship to ally/neutral/enemy.
--	Contains:
--		source :: LuaForce: The force that changed current diplomacy relationship.
--		destination :: LuaForce: The force which have to accept new diplomacy relationship.
--		player_index :: uint (optional): The player who cause the changing.
--		prev_relationship :: string: Previous relationship between forces.

return {
	on_ally = script.generate_event_name(),
	on_neutral = script.generate_event_name(),
	on_enemy = script.generate_event_name()
}
