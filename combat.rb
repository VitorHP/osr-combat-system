require 'debug'

Combatant = Struct.new("Combatant",
  :name,
  :ac,
  :max_armour,
  :armour,
  :health,
  :wounds,
  :atk,
  keyword_init: true
) do
  def take_damage
    if armor > 0
      armor -= 1
    else
      wounds += 1
    end
  end

  def is_alive?
    wounds < health
  end
end

fighter_1_plate_shield_two_handed = Combatant.new(
  name: "Fighter (plate shield 2hs)",
  ac: 7,
  max_armour: 3,
  armour: 3,
  health: 2,
  wounds: 0,
  atk: ['1d10+3']
)

fighter_1_plate_shield_longsword = Combatant.new(
  name: "Fighter (plate shield long)",
  ac: 7,
  max_armour: 3,
  armour: 3,
  health: 2,
  wounds: 0,
  atk: ['1d8+3']
)

fighter_1_plate_shield_shortsword = Combatant.new(
  name: "Fighter (plate shield short)",
  ac: 7,
  max_armour: 3,
  armour: 3,
  health: 2,
  wounds: 0,
  atk: ['1d6+3']
)

fighter_1_leather_shortsword = Combatant.new(
  name: "Fighter (leather short)",
  ac: 3,
  max_armour: 1,
  armour: 1,
  health: 2,
  wounds: 0,
  atk: ['1d6+3']
)

bugbear_shortsword = Combatant.new(
  name: "Bugbear (shortsword)",
  ac: 4,
  max_armour: 0,
  armour: 0,
  health: 3,
  wounds: 0,
  atk: ["1d6"],
)

bugbear_longsword = Combatant.new(
  name: "Bugbear (longsword)",
  ac: 4,
  max_armour: 0,
  armour: 0,
  health: 3,
  wounds: 0,
  atk: ["1d8"],
)


bugbear_dagger = Combatant.new( 
  name: "Bugbear (dagger)",
  ac: 4,
  max_armour: 0,
  armour: 0,
  health: 3,
  wounds: 0,
  atk: ["1d4"],
 )

goblin = Combatant.new( 
  name: "Goblin",
  ac: 3,
  max_armour: 0,
  armour: 0,
  health: 1,
  wounds: 0,
  atk: ["1d4"],
 )


combat = {
  init: "player",
  rounds: 1
}

def roll_dice(dice_string)
  dice_amount, dice_kind, bonus = dice_string.scan(/(\d+)d(\d+)\+?(\d+)?/).first

  result = 0
  crit = false
  miss = false

  result = Random.rand(dice_kind.to_i) + 1 

  miss = true if result == 1

  if result == dice_kind.to_i
    crit = true
    result += Random.rand(dice_kind.to_i) + 1 
  end

  [ result + bonus.to_i, crit, miss ]
end

def everyone_is_alive(side_a, side_b)
  side_a.is_alive? && side_b.is_alive?
end

def wound_system_combat(side_a, side_b, verbose = false)
  rounds = 0

  attacker = nil
  defender = nil

  while (everyone_is_alive(side_a, side_b)) do
    rounds += 1

    puts "Round #{rounds}" if verbose

    if (roll_dice("1d6").first < 4)
      attacker = side_a
      defender = side_b
    else
      attacker = side_b
      defender = side_a
    end

    attack(attacker, defender, verbose)
    attack(defender, attacker, verbose) if everyone_is_alive(side_a, side_b)
  end

  puts "Round: #{rounds} - #{report(side_a, side_b, rounds, verbose)}" if verbose
  side_a.is_alive? ? report_winner(side_a) : report_winner(side_b) if verbose

  report(side_a, side_b, rounds, verbose)
end

def report(side_a, side_b, rounds, verbose)
  { round: rounds, winner: side_a.is_alive? ? side_a.name : side_b.name }
end

def report_winner(side)
  puts "#{side.name} wins losing #{side.max_armour - side.armour} armour and #{side.wounds} wounds"
end

def damage(side, verbose)
  if side.armour > 0
    puts "#{side.name}: loses 1 armour" if verbose
    side.armour -= 1
  else
    puts "#{side.name}: takes a wound" if verbose
    side.wounds += 1
  end
end

def attack(attacker, defendant, verbose = false)
  attacker.atk.each do |atk|
    dice_roll, was_critical, was_miss = roll_dice(atk)

    puts "#{attacker.name} rolls #{dice_roll} against #{defendant.ac} #{was_critical ? 'Critical hit!' : ''}" if verbose

    if !was_miss && (dice_roll >= defendant.ac || was_critical)
      damage(defendant, verbose)
      # damage(defendant) if was_critical # not using double wound for every critical
    end
  end
end

def run_many(side_a, side_b)
  puts "#{side_a.name} vs #{side_b.name}" 

  res = (1..10000).each_with_object({}) do |i, res|
    combat_result = wound_system_combat(side_a.clone, side_b.clone)

    res[combat_result[:winner]] = 0 if res[combat_result[:winner]] == nil
    res[combat_result[:winner]] += 1
  end
end

puts run_many(fighter_1_leather_shortsword, goblin)
# puts run_many(bugbear_longsword, fighter_1_leather)
# puts run_many(fighter_1_plate_and_shield_shortsword.clone, fighter_1_plate_shield_longsword.clone)
# puts run_many(fighter_1_plate_shield_two_handed.clone, fighter_1_plate_shield_shortsword.clone)

# wound_system_combat(bugbear_dagger.clone, bugbear_longsword.clone, true)
# wound_system_combat(fighter_1_plate_shield_two_handed.clone, fighter_1_plate_shield_shortsword.clone, true)