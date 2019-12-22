require_relative '../20'

EXAMPLE_20_A = File.read('example20a.txt')
EXAMPLE_20_B = File.read('example20b.txt')
EXAMPLE_20_C = File.read('example20c.txt')

RSpec.describe DonutMaze do
  it "A knows the location of the various portals" do
    maze = DonutMaze.new EXAMPLE_20_A
    
    entry = 6 * maze.width + 9      # 135
    other_end = 8 * maze.width + 2  # 170
    
    expect(maze.portal_locations.length).to eq(8)
    expect(maze.portal_links[entry]).to eq(other_end)
    expect(maze.portal_links[other_end]).to eq(entry)
  end

  it "A knows the length of the best route to ZZ" do
    maze = DonutMaze.new EXAMPLE_20_A

    expect(maze.edge_costs[maze.origin][maze.destination]).to eq(26)
    expect(maze.best_path maze.origin, maze.destination).to eq(23)
  end

  it "A can tell if a location is on the outer edge" do
    maze = DonutMaze.new EXAMPLE_20_A

    expect(maze.is_outer? 51).to eq(true)
    expect(maze.is_outer? 170).to eq(true)
    expect(maze.is_outer? 135).to eq(false)
    expect(maze.is_outer? 275).to eq(true)
    expect(maze.is_outer? 216).to eq(false)
    expect(maze.is_outer? 317).to eq(true)
    expect(maze.is_outer? 263).to eq(false)
    expect(maze.is_outer? 349).to eq(true)
  end

  it "A knows the length of the best level conscious route to ZZ" do
    maze = DonutMaze.new EXAMPLE_20_A

    expect(maze.best_level_conscious_path maze.origin, maze.destination).to eq(26)
  end

  it "B knows the length of the best route to ZZ" do
    maze = DonutMaze.new EXAMPLE_20_B

    expect(maze.edge_costs[maze.origin]).not_to include(maze.destination)
    expect(maze.best_path maze.origin, maze.destination).to eq(58)
  end
end
