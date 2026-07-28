// Canonical registry for the raygui styles exposed by BitSpryte.
package themes

Kind :: enum i32 {
	Default,
	Amber,
	Ashes,
	Bluish,
	Candy,
	Cherry,
	Cyber,
	Dark,
	Enefete,
	Genesis,
	Jungle,
	Lavanda,
	RLTech,
	Sunny,
	Terminal,
}

// raygui controls use semicolon-delimited option text.
SELECTOR_TEXT :: cstring("Default;Amber;Ashes;Bluish;Candy;Cherry;Cyber;Dark;Enefete;Genesis;Jungle;Lavanda;RLTech;Sunny;Terminal")

file_name :: proc(theme: Kind) -> cstring {
	switch theme {
	case .Default:  return nil
	case .Amber:    return "styles/style_amber.rgs"
	case .Ashes:    return "styles/style_ashes.rgs"
	case .Bluish:   return "styles/style_bluish.rgs"
	case .Candy:    return "styles/style_candy.rgs"
	case .Cherry:   return "styles/style_cherry.rgs"
	case .Cyber:    return "styles/style_cyber.rgs"
	case .Dark:     return "styles/style_dark.rgs"
	case .Enefete:  return "styles/style_enefete.rgs"
	case .Genesis:  return "styles/style_genesis.rgs"
	case .Jungle:   return "styles/style_jungle.rgs"
	case .Lavanda:  return "styles/style_lavanda.rgs"
	case .RLTech:   return "styles/style_rltech.rgs"
	case .Sunny:    return "styles/style_sunny.rgs"
	case .Terminal: return "styles/style_terminal.rgs"
	}
	return nil
}

is_valid :: proc(value: i32) -> bool {
	return value >= i32(Kind.Default) && value <= i32(Kind.Terminal)
}
