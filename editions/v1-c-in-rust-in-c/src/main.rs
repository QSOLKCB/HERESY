use std::fs;
use std::io::Write;
use std::path::PathBuf;
use std::process::Command;

const C_GENERATOR: &str = r#"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

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
    if(!f){ fprintf(stderr, "write_file: fopen %s failed: %s\n", path, strerror(errno)); return -1; }
    size_t n = fwrite(contents, 1, strlen(contents), f);
    if(n != strlen(contents)){ fprintf(stderr, "write_file: short write %s\n", path); fclose(f); return -1; }
    fclose(f);
    return 0;
}

static int run(const char *cmd) {
    int rc = system(cmd);
    if(rc != 0){ fprintf(stderr, "cmd failed (%d): %s\n", rc, cmd); return -1; }
    return 0;
}

int main(void){
    puts("C-generator: emitting tiny C project...");
    if(write_file("alpha.c", ALPHA_SRC) < 0) return 1;
    if(write_file("beta.c", BETA_SRC) < 0) return 1;
    if(write_file("runner.c", RUNNER_SRC) < 0) return 1;
    if(run("gcc -Wall -g -O0 -c alpha.c -o alpha.o")) return 1;
    if(run("gcc -Wall -g -O0 -c beta.c -o beta.o")) return 1;
    if(run("gcc -Wall -g -O0 -c runner.c -o runner.o")) return 1;
    if(run("gcc -g -o heresy_exe alpha.o beta.o runner.o")) return 1;
    const char* once = getenv("HERESY_ONCE");
    if(!once || strcmp(once, "1") != 0){
        puts("(would re-invoke cargo here, but we're polite in CI)");
        // run("cargo build --quiet");
    } else {
        puts("recursion guard active; skipping cargo re-entry.");
    }
    return 0;
}
"#;

fn sh(cmd: &mut Command) -> std::io::Result<()> {
    let status = cmd.status()?;
    if status.success() { Ok(()) } else { Err(std::io::Error::new(std::io::ErrorKind::Other, format!("Command failed: {:?}", cmd))) }
}

fn main() -> std::io::Result<()> {
    let dir = PathBuf::from("target/heresy_c");
    fs::create_dir_all(&dir)?;
    let gen_c = dir.join("heretic_build.c");
    fs::File::create(&gen_c)?.write_all(C_GENERATOR.as_bytes())?;
    sh(Command::new("gcc").arg("-Wall").arg("-g").arg("-O0").arg(gen_c.file_name().unwrap()).arg("-o").arg("heretic_build").current_dir(&dir))?;
    let mut run_gen = Command::new("./heretic_build");
    run_gen.current_dir(&dir).env("HERESY_ONCE", "1");
    sh(&mut run_gen)?;
    let out = Command::new(dir.join("heresy_exe")).output()?;
    print!("{}", String::from_utf8_lossy(&out.stdout));
    eprint!("{}", String::from_utf8_lossy(&out.stderr));
    Ok(())
}
