use std::fs;
use std::io::Write;
use std::path::PathBuf;
use std::process::Command;

const C_GENERATOR: &str = r#"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

/* Heresy C generator:
   - Writes alpha.c, beta.c, runner.c
   - Compiles them to alpha.o, beta.o, runner.o
   - Links into heresy_exe
   - Optionally tries to call cargo again (disabled by env HERESY_ONCE=1)
*/

static const char *ALPHA_SRC =
"#include <stdio.h>\n"
"void alpha(void){ puts(\"Alpha says hello from heresy.\"); }\n";

static const char *BETA_SRC =
"#include <stdio.h>\n"
"void beta(void){ puts(\"Beta whispers: cargo is a Makefile.\"); }\n";

static const char *RUNNER_SRC =
"#include <stdio.h>\n"
"void alpha(void); void beta(void);\n"
"int main(void){ puts(\">>> runner.c starting\"); alpha(); beta(); puts(\">>> runner.c done\"); return 0; }\n";

static int write_file(const char* path, const char* contents) {
    FILE *f = fopen(path, "wb");
    if(!f){ fprintf(stderr, \"write_file: fopen %s failed: %s\\n\", path, strerror(errno)); return -1; }
    size_t n = fwrite(contents, 1, strlen(contents), f);
    if(n != strlen(contents)){ fprintf(stderr, \"write_file: short write %s\\n\", path); fclose(f); return -1; }
    fclose(f);
    return 0;
}

static int run(const char *cmd) {
    int rc = system(cmd);
    if(rc != 0){
        fprintf(stderr, \"cmd failed (%d): %s\\n\", rc, cmd);
        return -1;
    }
    return 0;
}

int main(void){
    puts("🔧 C-generator: emitting tiny C project (alpha,beta,runner)...");
    if(write_file("alpha.c", ALPHA_SRC) < 0) return 1;
    if(write_file("beta.c",  BETA_SRC)  < 0) return 1;
    if(write_file("runner.c",RUNNER_SRC)< 0) return 1;

    puts("🧱 compiling objects...");
    if(run("gcc -Wall -g -O0 -c alpha.c -o alpha.o")) return 1;
    if(run("gcc -Wall -g -O0 -c beta.c  -o beta.o" )) return 1;
    if(run("gcc -Wall -g -O0 -c runner.c -o runner.o")) return 1;

    puts("🔗 linking heresy_exe...");
    if(run("gcc -g -o heresy_exe alpha.o beta.o runner.o")) return 1;
    puts("🎉 built ./heresy_exe");

    /* Optional ouroboros poke (disabled by HERESY_ONCE=1) */
    const char* once = getenv("HERESY_ONCE");
    if(!once || strcmp(once, "1") != 0){
        puts("♻️  (would re-invoke cargo here, but we're polite in CI)");
        // run("cargo build --quiet"); // uncomment for maximum looping chaos (not recommended)
    } else {
        puts("🛑 recursion guard (HERESY_ONCE=1) active; skipping cargo re-entry.");
    }
    return 0;
}
"#;

fn sh(cmd: &mut Command) -> std::io::Result<()> {
    let status = cmd.status()?;
    if !status.success() {
        Err(std::io::Error::new(
            std::io::ErrorKind::Other,
            format!("Command failed: {:?}", cmd),
        ))
    } else {
        Ok(())
    }
}

fn main() -> std::io::Result<()> {
    // Stage dir for the embedded C project
    let mut dir = PathBuf::from("target/heresy_c");
    fs::create_dir_all(&dir)?;

    // Write generator C file
    let gen_c = dir.join("heretic_build.c");
    {
        let mut f = fs::File::create(&gen_c)?;
        f.write_all(C_GENERATOR.as_bytes())?;
    }

    // Compile the generator
    println!("🔧 compiling embedded C generator 👉 {}", gen_c.display());
    sh(Command::new("gcc")
        .arg("-Wall").arg("-g").arg("-O0")
        .arg(gen_c.file_name().unwrap())
        .arg("-o").arg("heretic_build")
        .current_dir(&dir))?;

    // Run the generator with recursion guard
    println!("🌀 running C generator…");
    let mut run_gen = Command::new("./heretic_build");
    run_gen.current_dir(&dir);
    run_gen.env("HERESY_ONCE", "1");
    sh(&mut run_gen)?;

    // Show the result
    let exe = dir.join("heresy_exe");
    println!("✅ generator produced: {}", exe.display());

    // Demo run
    println!("▶️  executing heresy_exe:");
    let out = Command::new(exe).output()?;
    print!("{}", String::from_utf8_lossy(&out.stdout));
    eprint!("{}", String::from_utf8_lossy(&out.stderr));

    println!("🎯 Done. Maximum C-in-Rust heresy achieved.");
    Ok(())
}
