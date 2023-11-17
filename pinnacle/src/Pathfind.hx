package;

import Location;

// Node class for pathfinding
class Node {
    public var coord : Coordinate;
    public var g : Float; // cost of getting to this node
    public var h : Float; // heuristic cost to the goal
    public var f : Float; // total cost (g + h)
    public var parent : Node;

    public function new(coord : Coordinate, g : Float, h : Float, parent : Node) {
        this.coord = coord;
        this.g = g;
        this.h = h;
        this.f = g + h;
        this.parent = parent;
    }

    public function hash() : String {
        return coord.hash();
    }
}

function getRoute(start : Coordinate, goal : Coordinate, location : Location) : Array<Coordinate> {

    var openSet : Map<String, Node> = new Map<String, Node>();
    var closedSet : Map<String, Bool> = new Map<String, Bool>();

    var initial = new Node(start, 0, start.distance(goal), null);
    openSet.set(start.hash(), initial);

    while (true) {
        var openSetEmpty = true;
        for (entry in openSet.keyValueIterator()) {
            openSetEmpty = false;
            break;
        }

        if (openSetEmpty) {
            break;
        }
        var current : Node = getLowestFNode(openSet);
        //trace(current.coord.x + ", " + current.coord.y + ", " + current.coord.z);

        if ((current.coord.equals(goal)) || current.g > 20) {
            return reconstructPath(current);
        }
        var hash = current.hash();

        openSet.remove(hash);
        closedSet.set(hash, true);

        for (neighbor in current.coord.getNeighbors(location)) {
            var nhash = neighbor.hash();
            if (closedSet.exists(nhash))
                continue;

            var tentativeGScore = current.g + distanceBetween(current.coord, neighbor);

            if (openSet.exists(nhash)) {
                var eNeighbor = openSet.get(nhash);
                if (tentativeGScore < eNeighbor.g) {
                    eNeighbor.parent = current;
                    eNeighbor.g = tentativeGScore;
                }
            } else {
                var neighborNode = new Node(neighbor, tentativeGScore, neighbor.distance(goal), current);
                openSet.set(nhash, neighborNode);
            }
        }
    }

    return new Array<Coordinate>(); // Return empty array if no path is found
}

// Distance between two nodes (assumed to be 1 for simplicity)
function distanceBetween(coord1 : Coordinate, coord2 : Coordinate) : Float {
    return 1.0;
}


// Select node with lowest F cost in a list
function getLowestFNode(nodes : Map<String, Node>) : Node {
    var lowest : Node = null;

    for (entry in nodes.keyValueIterator()) {
        var node = entry.value;
        if (lowest == null || node.f < lowest.f) {
            lowest = node;
        }
    }

    return lowest;
}

// Reconstructs the path from a given node to the start by following parent nodes
function reconstructPath(endNode : Node) : Array<Coordinate> {
    var path : Array<Coordinate> = [];
    var current : Null<Node> = endNode;

    while (current != null) {
        path.push(current.coord);  // Create a point with appropriate parameters
        current = current.parent;
    }

    path.reverse();
    if (path.length > 12)
        path.resize(12);
    path.shift();
    return path;
}
