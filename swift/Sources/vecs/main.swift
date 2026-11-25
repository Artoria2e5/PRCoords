import Foundation
import PRCoords

// Dump the eight-column test vector layout for py/checkvecs.py.

let args = CommandLine.arguments
let text: String
if args.count > 1 {
    guard let contents = try? String(contentsOfFile: args[1], encoding: .utf8) else {
        FileHandle.standardError.write("cannot open \(args[1])\n".data(using: .utf8)!)
        exit(1)
    }
    text = contents
} else {
    let data = FileHandle.standardInput.readDataToEndOfFile()
    text = String(data: data, encoding: .utf8) ?? ""
}

for line in text.split(separator: "\n") {
    let fields = line.split(whereSeparator: { $0 == " " || $0 == "\t" })
        .compactMap { Double($0) }
    if fields.count < 2 {
        continue
    }
    let p = Coords(fields[0], fields[1])
    let w = wgsGcj(p)
    let g = gcjBd(p)
    let b = wgsBd(p)
    print(String(format: "%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g\t%.17g",
                 p.lat, p.lon, w.lat, w.lon, g.lat, g.lon, b.lat, b.lon))
}
