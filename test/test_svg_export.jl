@testset "Export Formats (REQ-ECO-011, REQ-ECO-012)" begin
    # === SVG Export ===
    @testset "SVG Export" begin
        @testset "save_svg produces valid SVG" begin
            b = Board("svg_basic", xlim=(-5, 5), ylim=(-5, 5))
            push!(b, point(1, 2; name="P"))

            tmpfile = tempname() * ".svg"
            try
                result = save_svg(tmpfile, b)
                @test result == tmpfile
                @test isfile(tmpfile)

                content = read(tmpfile, String)
                @test startswith(content, "<?xml")
                @test occursin("<svg", content)
                @test occursin("xmlns=\"http://www.w3.org/2000/svg\"", content)
            finally
                rm(tmpfile; force=true)
            end
        end

        @testset "save() dispatches to SVG for .svg extension" begin
            b = Board("svg_dispatch", xlim=(-5, 5), ylim=(-5, 5))
            push!(b, point(0, 0; name="O"))

            tmpfile = tempname() * ".svg"
            try
                result = save(tmpfile, b)
                @test result == tmpfile
                content = read(tmpfile, String)
                @test startswith(content, "<?xml")
                @test occursin("<svg", content)
            finally
                rm(tmpfile; force=true)
            end
        end

        @testset "SVG with multiple elements" begin
            b = Board("svg_multi", xlim=(-5, 5), ylim=(-5, 5))
            p1 = point(0, 0; name="O")
            p2 = point(3, 4; name="A")
            push!(b, p1)
            push!(b, p2)
            push!(b, line(p1, p2; strokeColor="red"))
            push!(b, circle(p1, 3; strokeColor="blue"))

            tmpfile = tempname() * ".svg"
            try
                save(tmpfile, b)
                content = read(tmpfile, String)
                @test occursin("<svg", content)
                @test length(content) > 1000
            finally
                rm(tmpfile; force=true)
            end
        end
    end

    # === PNG Export ===
    @testset "PNG Export" begin
        @testset "save_png produces valid PNG" begin
            b = Board("png_basic", xlim=(-5, 5), ylim=(-5, 5))
            push!(b, point(1, 2; name="P"))

            tmpfile = tempname() * ".png"
            try
                result = save_png(tmpfile, b)
                @test result == tmpfile
                @test isfile(tmpfile)

                # Check PNG magic bytes (89 50 4E 47 0D 0A 1A 0A)
                bytes = read(tmpfile)
                @test bytes[1] == 0x89
                @test bytes[2] == 0x50  # P
                @test bytes[3] == 0x4E  # N
                @test bytes[4] == 0x47  # G
                @test length(bytes) > 100
            finally
                rm(tmpfile; force=true)
            end
        end

        @testset "save() dispatches to PNG for .png extension" begin
            b = Board("png_dispatch", xlim=(-5, 5), ylim=(-5, 5))
            push!(b, point(0, 0; name="O"))

            tmpfile = tempname() * ".png"
            try
                result = save(tmpfile, b)
                @test result == tmpfile
                bytes = read(tmpfile)
                @test bytes[1:4] == UInt8[0x89, 0x50, 0x4E, 0x47]
            finally
                rm(tmpfile; force=true)
            end
        end

        @testset "save_png with scale factor" begin
            b = Board("png_scale", xlim=(-5, 5), ylim=(-5, 5))
            push!(b, point(1, 1; name="A"))

            tmpfile1 = tempname() * ".png"
            tmpfile2 = tempname() * ".png"
            try
                save_png(tmpfile1, b; scale=1)
                save_png(tmpfile2, b; scale=2)
                # 2× scale should produce a larger file
                @test filesize(tmpfile2) > filesize(tmpfile1)
            finally
                rm(tmpfile1; force=true)
                rm(tmpfile2; force=true)
            end
        end

        @testset "save() with scale kwarg for PNG" begin
            b = Board("png_save_scale", xlim=(-5, 5), ylim=(-5, 5))
            push!(b, point(0, 0))

            tmpfile = tempname() * ".png"
            try
                result = save(tmpfile, b; scale=2)
                @test result == tmpfile
                @test isfile(tmpfile)
            finally
                rm(tmpfile; force=true)
            end
        end
    end

    # === PDF Export ===
    @testset "PDF Export" begin
        @testset "save_pdf produces valid PDF" begin
            b = Board("pdf_basic", xlim=(-5, 5), ylim=(-5, 5))
            push!(b, point(1, 2; name="P"))

            tmpfile = tempname() * ".pdf"
            try
                result = save_pdf(tmpfile, b)
                @test result == tmpfile
                @test isfile(tmpfile)

                # Check PDF magic bytes (%PDF-)
                content = read(tmpfile, String)
                @test startswith(content, "%PDF-")
                @test length(content) > 100
            finally
                rm(tmpfile; force=true)
            end
        end

        @testset "save() dispatches to PDF for .pdf extension" begin
            b = Board("pdf_dispatch", xlim=(-5, 5), ylim=(-5, 5))
            push!(b, point(0, 0; name="O"))

            tmpfile = tempname() * ".pdf"
            try
                result = save(tmpfile, b)
                @test result == tmpfile
                content = read(tmpfile, String)
                @test startswith(content, "%PDF-")
            finally
                rm(tmpfile; force=true)
            end
        end
    end

    # === General save() tests ===
    @testset "save() general" begin
        @testset "save() errors on unsupported extension" begin
            b = Board("save_err")
            @test_throws ErrorException save(tempname() * ".gif", b)
            @test_throws ErrorException save(tempname() * ".bmp", b)
        end

        @testset "save() still works for .html" begin
            b = Board("save_html", xlim=(-5, 5), ylim=(-5, 5))
            push!(b, point(1, 1))

            tmpfile = tempname() * ".html"
            try
                save(tmpfile, b)
                content = read(tmpfile, String)
                @test occursin("<!DOCTYPE html>", content)
            finally
                rm(tmpfile; force=true)
            end
        end
    end
end
