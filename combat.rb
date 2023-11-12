require 'debug'
require 'bigdecimal'
require 'bigdecimal/util'

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
    if armour > 0
      armour -= 1
    else
      wounds += 1
    end
  end

  def is_alive?
    wounds <= health
  end

  def reset
    self.wounds = 0
    self.armour = max_armour
  end
end

Party = Struct.new("Party",
  :members
) do
  def name
    members.map { |m| m.name }.join(", ")
  end

  def alive_members
    members.select { |m| m.is_alive? }
  end

  def is_alive?
    members.any? { |m| m.is_alive? }
  end

  def report
    members.each do |m|
      if m.is_alive?
        puts "#{m.name} wins losing #{m.max_armour - m.armour} armour and #{m.wounds} wounds"
      else
        puts "#{m.name} died"
      end
    end
  end

  def reset
    members.map(&:reset)
  end

  def deaths
    members.reject(&:is_alive?).count
  end
end

knight_1 = Combatant.new(
  name: "Knight 1",
  ac: 7,
  max_armour: 2,
  armour: 2,
  health: 2,
  wounds: 0,
  atk: ['1d8+1']
)

knight_3 = Combatant.new(
  name: "Knight 3",
  ac: 9,
  max_armour: 2,
  armour: 2,
  health: 2,
  wounds: 0,
  atk: ['1d8+2']
)

knight_5 = Combatant.new(
  name: "Knight 5",
  ac: 9,
  max_armour: 2,
  armour: 2,
  health: 3,
  wounds: 0,
  atk: ['1d8+3']
)

hunter_1 = Combatant.new(
  name: "Hunter 1",
  ac: 2,
  max_armour: 0,
  armour: 0,
  health: 1,
  wounds: 0,
  atk: ['1d6']
)

hunter_5 = Combatant.new(
  name: "Hunter 5",
  ac: 4,
  max_armour: 2,
  armour: 2,
  health: 3,
  wounds: 0,
  atk: ['1d6+3']
)

cleric_1 = Combatant.new(
  name: "Cleric 1",
  ac: 5,
  max_armour: 1,
  armour: 1,
  health: 0,
  wounds: 0,
  atk: ['1d8']
)

cleric_3 = Combatant.new(
  name: "Cleric 3",
  ac: 7,
  max_armour: 3,
  armour: 3,
  health: 1,
  wounds: 0,
  atk: ['1d8+1']
)

cleric_5 = Combatant.new(
  name: "Cleric 5",
  ac: 9,
  max_armour: 2,
  armour: 2,
  health: 2,
  wounds: 0,
  atk: ['1d8+4']
)

thief_1 = Combatant.new(
  name: "Thief 1",
  ac: 2,
  max_armour: 0,
  armour: 0,
  health: 1,
  wounds: 0,
  atk: ['1d8+3']
)

thief_3 = Combatant.new(
  name: "Thief 3",
  ac: 4,
  max_armour: 2,
  armour: 2,
  health: 0,
  wounds: 0,
  atk: ['1d8+3']
)

thief_5 = Combatant.new(
  name: "Thief 5",
  ac: 4,
  max_armour: 2,
  armour: 2,
  health: 2,
  wounds: 0,
  atk: ['1d6+2']
)

bugbear = Combatant.new( 
  name: "Bugbear",
  ac: 4,
  max_armour: 1,
  armour: 1,
  health: 3,
  wounds: 0,
  atk: ["1d6+2"],
 )

goblin = Combatant.new( 
  name: "Goblin",
  ac: 3,
  max_armour: 0,
  armour: 0,
  health: 0,
  wounds: 0,
  atk: ["1d4"],
 )

werewolf = Combatant.new( 
  name: "Werewolf",
  ac: 4,
  max_armour: 2,
  armour: 2,
  health: 4,
  wounds: 0,
  atk: ["1d6+3"],
)

wolf = Combatant.new( 
  name: "Werewolf",
  ac: 4,
  max_armour: 2,
  armour: 2,
  health: 4,
  wounds: 0,
  atk: ["1d6+3"],
)

owlbear = Combatant.new( 
  name: "Owlbear",
  ac: 4,
  max_armour: 2,
  armour: 2,
  health: 5,
  wounds: 0,
  atk: ["1d8+4", "1d8+4", "1d8+4"],
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

  [ result + bonus.to_i, crit, miss, dice_kind.to_i ]
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
  { round: rounds, heroes_won: side_a.is_alive? ? true : false, deaths: side_a.deaths }
end

def report_winner(side)
  side.report
end

def damage(side, verbose)
  if side.armour > 0
    puts "#{side.name}: loses 1 armour" if verbose
    side.armour -= 1
  else
    puts "#{side.name}: takes a wound" if verbose
    side.wounds += 1
    puts "#{side.name}: dies" if verbose && side.wounds > side.health
  end
end

def attack(offense, defense, verbose = false)
  offense.alive_members.each do |attacker|
    attacker.atk.each do |atk|
      dice_roll, was_critical, was_miss, dice_kind = roll_dice(atk)
      defender = defense.alive_members.shuffle.first

      next if defender.nil?

      puts "#{attacker.name} rolls #{dice_roll} against #{defender.ac} #{was_critical ? 'Critical hit!' : ''} #{was_miss ? 'Critical miss!' : ''}" if verbose

      if !was_miss && (dice_roll >= defender.ac || was_critical)
        damage(defender, verbose)
        damage(defender, verbose) if defender.is_alive? && was_critical && dice_kind > 4
      end
    end if defense.is_alive?
  end
end

def run_many(side_a, side_b)
  puts "#{side_a.name} vs #{side_b.name}" 

  res = (1..10000).each_with_object({ deaths: {}}) do |i, res|
    side_a.reset
    side_b.reset

    combat_result = wound_system_combat(side_a, side_b)

    res[:wins] ||= 0 
    res[:wins] += 1 if combat_result[:heroes_won]

    res[:deaths][combat_result[:deaths].to_s] ||= 0
    res[:deaths][combat_result[:deaths].to_s] += 1
  end


  puts "heroes won #{(res[:wins].to_d / 100000 * 100).truncate(2)}% of the fights"

  res[:deaths].to_a.sort_by{ |r| r.first.to_i }.each do |(death_count, amount)|
    puts "#{((amount.to_f / 10000) * 100).round(2)}% of combats had #{death_count} deaths"
  end
end


run_many(Party.new([knight_1, thief_1, cleric_1, hunter_1]), Party.new([goblin.clone, goblin.clone, goblin.clone, goblin.clone, goblin.clone, goblin.clone]))
# run_many(Party.new([knight_1, thief_1, cleric_1, hunter_1]), Party.new([bugbear.clone, bugbear.clone]))
# run_many(Party.new([knight_1, thief_1, cleric_1, hunter_1]), Party.new([owlbear.clone]))

# wound_system_combat(Party.new([knight_1, thief_1, cleric_1, hunter_1]), Party.new([owlbear.clone]), true)
# wound_system_combat(Party.new([knight_1, thief_1, cleric_1, hunter_1]), Party.new([bugbear.clone, bugbear.clone, bugbear.clone, bugbear.clone]), true)
# wound_system_combat(Party.new([knight_5, thief_5, cleric_5, hunter_5]), Party.new([bugbear.clone, bugbear.clone, bugbear.clone, goblin.clone, goblin.clone]), true)