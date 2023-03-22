module Combat
  module Equipment
    PIECES  = { long_sword:       { name:       "Long Sword",
                                    body_part:  [ :left_hand, :right_hand ],
                                    effects:    [ { type: :buff, on: :attack, value: 2 } ] },
                poisoned_dagger:  { name:       "Poisoned Dagger",
                                    body_part:  [ :left_hand, :right_hand ],
                                    effects:    [ { type: :buff, on: :attack, value: 1 },
                                                  { type: :ailment, name: 'poison', on: :health, value: 1..3, turns: 3 } ] },
                magic_sword:      { name:       "Magic Sword",
                                    body_part:  [ :left_hand, :right_hand ],
                                    effects:    [ { type: :buff, on: :attack, value: 1 },
                                                  { type: :buff, on: :magic_attack, value: 1 } ] },
                leather_armor:    { name:       'Leather Armor',
                                    body_part:  [ :torso ],
                                    effects:    [ { type: :buff, on: :defense, value: 2 } ] },
                amulet:           { name:       'Amuleleft_handt',
                                    body_part:  [ :neck ],
                                    effects:    [ { type: :buff, on: :magic_defense, value: 2 } ] },
                magic_helm:       { name:       'Magic Helm',
                                    body_part:  [ :head ],
                                    effects:    [ { type: :buff, on: :defense, value: 1 },
                                                  { type: :buff, on: :magic_defense, value: 1 } ] } }
  end
end
