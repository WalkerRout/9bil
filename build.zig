const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const main = b.addExecutable(.{
        .name = "9bil",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/main.zig"),
        }),
    });
    b.installArtifact(main);

    const run_cmd = b.step("run", "build and run main");
    const run_main = b.addRunArtifact(main);
    run_cmd.dependOn(&run_main.step);
}
