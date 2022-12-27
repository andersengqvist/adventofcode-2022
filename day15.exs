defmodule Distance do
  def manhattan({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end
end

defmodule Sensor do

  defstruct [:position, :closest_beacon, :distance]

  def new(position, closest_beacon) do
    distance = Distance.manhattan(position, closest_beacon)
    %Sensor{position: position, closest_beacon: closest_beacon, distance: distance}
  end

  def x_pos(sensor) do
    elem(sensor.position, 0)
  end

  def y_pos(sensor) do
    elem(sensor.position, 1)
  end

  def beacon_x_pos(sensor) do
    elem(sensor.closest_beacon, 0)
  end

  def beacon_y_pos(sensor) do
    elem(sensor.closest_beacon, 1)
  end

  def out_of_range?(sensor, point) do
    distance = Distance.manhattan(sensor.position, point)
    distance > sensor.distance
  end

  def in_range_step_x(sensor, {_x, y} = point) do
    if out_of_range?(sensor, point) do
      {:false, point}
    else
      # Find first x that is out of range of this sensor
      new_x = sensor.distance - abs(y_pos(sensor) - y) + x_pos(sensor) + 1
      {:true, {new_x, y}}
    end

  end
end

defmodule Zone do

  defstruct [sensors: %{}, beacons: MapSet.new(), min_x: 100000, max_x: -100000, min_y: 100000, max_y: -100000]

  def new() do
    %Zone{}
  end

  def put_sensor(zone, sensor) do
    x_min = min(zone.min_x, Sensor.x_pos(sensor) - sensor.distance)
    x_max = max(zone.max_x, Sensor.x_pos(sensor) + sensor.distance)
    y_min = min(zone.min_y, Sensor.y_pos(sensor) - sensor.distance)
    y_max = max(zone.max_y, Sensor.y_pos(sensor) + sensor.distance)

    new_sensors = Map.put(zone.sensors, sensor.position, sensor)
    new_beacons = MapSet.put(zone.beacons, sensor.closest_beacon)
    %Zone{sensors: new_sensors, beacons: new_beacons, min_x: x_min, max_x: x_max, min_y: y_min, max_y: y_max}
  end

  def num_instances_where_beacon_cannot_be_present_at_line(zone, line) do
    a = num_points_in_sensor_range_on_line(Map.values(zone.sensors), {zone.min_x, line}, zone.max_x, 0)
    b = num_beacons_on_line(MapSet.to_list(zone.beacons), line, 0)
    a - b
  end

  def num_points_in_sensor_range_on_line(_sensors, {curr_x, _curr_y}, max_x, acc) when curr_x > max_x do
    acc
  end
  def num_points_in_sensor_range_on_line(sensors, point, max_x, acc) do
    {new_point, num_in_range} = scan_sensor_on_line(sensors, point)
    num_points_in_sensor_range_on_line(sensors, new_point, max_x, acc + num_in_range)
  end

  def scan_sensor_on_line([], {x, y}) do
    {{x + 1, y}, 0}
  end
  def scan_sensor_on_line([sensor | rest], {x, _y} = point) do
    case Sensor.in_range_step_x(sensor, point) do
      {:true, {new_x, _y} = new_point} -> {new_point, new_x - x}
      {:false, _point} -> scan_sensor_on_line(rest, point)
    end
  end

  def num_beacons_on_line([], _line, acc) do
    acc
  end
  def num_beacons_on_line([beacon | rest], line, acc) do
    if elem(beacon, 1) == line do
      num_beacons_on_line(rest, line, acc + 1)
    else
      num_beacons_on_line(rest, line, acc)
    end
  end

  def tuning_frequency(zone, x_max, y_max) do
    {x, y} = find_first_point_out_of_range(Map.values(zone.sensors), {0, 0}, x_max, y_max)
    x * 4000000 + y
  end
  defp find_first_point_out_of_range(sensors, {curr_x, curr_y}, x_max, y_max) when curr_x > x_max do
    find_first_point_out_of_range(sensors, {0, curr_y + 1}, x_max, y_max)
  end
  defp find_first_point_out_of_range(_sensors, {_curr_x, curr_y}, _x_max, y_max) when curr_y > y_max do
    {-1, -1}
  end
  defp find_first_point_out_of_range(sensors, point, x_max, y_max) do
    case find_point_out_of_range_on_line(sensors, point) do
      {:true, new_point} -> new_point
      {:false, new_point} -> find_first_point_out_of_range(sensors, new_point, x_max, y_max)
    end
  end

  def find_point_out_of_range_on_line([], point) do
    {:true, point}
  end
  def find_point_out_of_range_on_line([sensor | rest], point) do
    case Sensor.in_range_step_x(sensor, point) do
      {:true, new_point} -> {:false, new_point}
      {:false, _point} -> find_point_out_of_range_on_line(rest, point)
    end
  end

  def print(zone) do
    print(zone, zone.min_x, zone.min_y)
  end

  defp print(%Zone{min_x: min_x, max_x: max_x} = zone, curr_x, curr_y) when curr_x > max_x do
    IO.puts("")
    print(zone, min_x, curr_y + 1)
  end
  defp print(%Zone{max_y: max_y} = zone, _curr_x, curr_y) when curr_y > max_y do
    zone
  end
  defp print(zone, curr_x, curr_y) do
    IO.write element_at(zone, {curr_x, curr_y})
    print(zone, curr_x + 1, curr_y)
  end

  defp element_at(zone, point) do
    if Map.has_key?(zone.sensors, point) do
      "S"
    else
      if MapSet.member?(zone.beacons, point) do
        "B"
      else
        if possible_beacon_at?(zone, point) do
          "."
        else
          "#"
        end
      end
    end
  end

  defp possible_beacon_at?(zone, point) do
    if MapSet.member?(zone.beacons, point) do
      true # Certain there is a beacon here
    else
      sensors_out_of_range?(Map.values(zone.sensors), point)
    end
  end

  defp sensors_out_of_range?([], _point) do
    true
  end
  defp sensors_out_of_range?([sensor | rest], point) do
    if Sensor.out_of_range?(sensor, point) do
      sensors_out_of_range?(rest, point)
    else
      false
    end
  end
end

defmodule ZoneBuilder do

  def build(input) do
    zone = Zone.new()
    parse(input, zone)
  end

  defp parse([], zone) do zone end
  defp parse([line | rest], zone) do
    new_zone = parse_line(line, zone)
    parse(rest, new_zone)
  end

  defp parse_line(line, zone) do
    [_, sx, sy, bx, by] = Regex.run(~r/Sensor at x=(-?\d+), y=(-?\d+): closest beacon is at x=(-?\d+), y=(-?\d+)/, line)
    sensor = Sensor.new({String.to_integer(sx), String.to_integer(sy)}, {String.to_integer(bx), String.to_integer(by)})
    Zone.put_sensor(zone, sensor)
  end
end

defmodule Day15 do

  def part1() do
    input = File.read!("res/day15.txt") |> String.split("\n", trim: true)
    zone = ZoneBuilder.build(input)
    #Zone.print(zone)
    res = Zone.num_instances_where_beacon_cannot_be_present_at_line(zone, 2000000)
    IO.puts ["Part 1: ", Integer.to_string(res)]
  end

  def part2() do
    input = File.read!("res/day15.txt") |> String.split("\n", trim: true)
    zone = ZoneBuilder.build(input)
    res = Zone.tuning_frequency(zone, 4000000, 4000000)
    IO.puts ["Part 2: ", Integer.to_string(res)]
  end

  def test_it() do
    input = [
      "Sensor at x=2, y=18: closest beacon is at x=-2, y=15",
      "Sensor at x=9, y=16: closest beacon is at x=10, y=16",
      "Sensor at x=13, y=2: closest beacon is at x=15, y=3",
      "Sensor at x=12, y=14: closest beacon is at x=10, y=16",
      "Sensor at x=10, y=20: closest beacon is at x=10, y=16",
      "Sensor at x=14, y=17: closest beacon is at x=10, y=16",
      "Sensor at x=8, y=7: closest beacon is at x=2, y=10",
      "Sensor at x=2, y=0: closest beacon is at x=2, y=10",
      "Sensor at x=0, y=11: closest beacon is at x=2, y=10",
      "Sensor at x=20, y=14: closest beacon is at x=25, y=17",
      "Sensor at x=17, y=20: closest beacon is at x=21, y=22",
      "Sensor at x=16, y=7: closest beacon is at x=15, y=3",
      "Sensor at x=14, y=3: closest beacon is at x=15, y=3",
      "Sensor at x=20, y=1: closest beacon is at x=15, y=3"
    ]
    zone = ZoneBuilder.build(input)
    #Zone.print(zone)
    26 = Zone.num_instances_where_beacon_cannot_be_present_at_line(zone, 10)
    56000011 = Zone.tuning_frequency(zone, 20, 20)
  end

end

IO.puts "Day 15"
Day15.test_it()
Day15.part1()
Day15.part2()