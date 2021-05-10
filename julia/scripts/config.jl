function _getos()::String
    if Sys.iswindows()
        "windows"
    elseif Sys.islinux()
        "linux"
    else
        lowercase(string(Sys.KERNEL))
    end
end

const DATA_DIR = joinpath(pwd(), "..", "data", "matrix_market")
const OUTPUT_DIR = mkpath(joinpath(pwd(), "output", _getos()))
