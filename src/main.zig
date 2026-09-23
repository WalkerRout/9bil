const std = @import("std");

pub fn Machine(comptime T: type, comptime N: usize) type {
    return struct {
        const Self = @This();

        const Filter = *const fn ([]const T) bool;

        filters: []const Filter = &[_]Filter{},
        alphabet: []const T,
        last_name: [N]T,
        index: usize,
        limit: usize,

        pub fn init(alphabet: []const T) Self {
            return .{
                .alphabet = alphabet,
                .last_name = undefined,
                .index = 0,
                // cache limit
                .limit = std.math.pow(usize, alphabet.len, N),
            };
        }

        pub fn iterator(self: *Self) MachineIterator(T, N) {
            return .{
                .machine = self,
            };
        }
    };
}

pub fn MachineIterator(comptime T: type, comptime N: usize) type {
    return struct {
        const Self = @This();

        machine: *Machine(T, N),

        pub fn next(self: *Self) ?[]const T {
            const machine = self.machine;
            while (true) {
                if (machine.index >= machine.limit) {
                    return null;
                }
                var idx = machine.index;
                machine.index += 1;
                const k = machine.alphabet.len;
                for (0..N) |rpos| {
                    const pos = N - 1 - rpos;
                    machine.last_name[pos] = machine.alphabet[idx % k];
                    idx /= k;
                }
                var rejected = false;
                for (machine.filters) |f| {
                    if (!f(machine.last_name[0..])) {
                        rejected = true;
                        break;
                    }
                }
                if (!rejected) return machine.last_name[0..];
            }
        }
    };
}

const English = enum {
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,
};

pub fn main(init: std.process.Init) !void {
    _ = init;
    const all_letters = [_]English{
        .A, .B, .C, .D, .E, .F, .G, .H, .I, .J, .K, .L, .M, .N, .O, .P, .Q, .R, .S, .T, .U, .V, .W, .X, .Y, .Z,
    };
    // log26(9'000'000'000) ~= 5
    var machine = Machine(English, 5).init(all_letters[0..]);
    var iter = machine.iterator();
    while (iter.next()) |name| {
        for (name) |letter| {
            std.debug.print("{s}", .{std.enums.tagName(English, letter).?});
        }
        std.debug.print("\n", .{});
    }
}
