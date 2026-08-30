import Darwin
import Foundation
import SwitcherCore
import SystemPorts

public struct LibprocProcessHierarchy: ProcessHierarchy {
    private static let pathBufferSize = 4 * Int(PATH_MAX)

    public init() {}

    public func parent(of process: ProcessIdentifier) -> ProcessIdentifier? {
        var info = proc_bsdshortinfo()
        let size = Int32(MemoryLayout<proc_bsdshortinfo>.stride)
        let written = withUnsafeMutablePointer(to: &info) {
            proc_pidinfo(process.rawValue, PROC_PIDT_SHORTBSDINFO, 0, $0, size)
        }
        guard written == size else { return nil }
        let parent = Int32(bitPattern: info.pbsi_ppid)
        return parent > 0 ? ProcessIdentifier(rawValue: parent) : nil
    }

    public func executablePath(of process: ProcessIdentifier) -> String? {
        var buffer = [UInt8](repeating: 0, count: Self.pathBufferSize)
        let written = proc_pidpath(process.rawValue, &buffer, UInt32(buffer.count))
        guard written > 0 else { return nil }
        return String(bytes: buffer[..<Int(written)], encoding: .utf8)
    }
}
