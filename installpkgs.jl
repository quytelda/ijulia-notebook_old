import Pkg

Pkg.update()
for pkgname in ARGS
    Pkg.add(strip("$pkgname"))
end
Pkg.precompile()
