require_relative '../20'

EXAMPLE_20_A = File.read('example20a.txt')
EXAMPLE_20_B = File.read('example20b.txt')

RSpec.describe DonutMaze do
  it "A knows how the location of the various portals" do
    maze = DonutMaze.new EXAMPLE_20_A
    
    entry = 6 * maze.width + 9      # 135
    other_end = 8 * maze.width + 2  # 170
    
    expect(maze.portal_locations.length).to eq(8)
    expect(maze.portal_links[entry]).to eq(other_end)
    expect(maze.portal_links[other_end]).to eq(entry)
  end

  it "A knows how the length of the best route to ZZ" do
    maze = DonutMaze.new EXAMPLE_20_A

    expect(maze.edge_costs[maze.origin][maze.destination]).to eq(26)
    expect(maze.best_path maze.origin, maze.destination).to eq(23)
  end

  it "B knows how the length of the best route to ZZ" do
    maze = DonutMaze.new EXAMPLE_20_B

    expect(maze.edge_costs[maze.origin]).not_to include(maze.destination)
    expect(maze.best_path maze.origin, maze.destination).to eq(58)
  end
end
