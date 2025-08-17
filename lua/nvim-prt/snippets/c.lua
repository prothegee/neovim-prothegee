return {
    int_main = "int main() { return 0; }",
    int_main_args = "int main(int argc, char* argv[]) { return 0; }",

    for_i = "for (int i = 0; i < var; i++) {\n    // TODO\n}",

    struct_t = "struct Struct_t {\n    // TODO\n}; // Struct_t",

    enum_e = "enum Enum_e {\n    // TODO\n}; // Enum_e",

    include_guard = [[
#ifndef THIS_FILE_H
#define THIS_FILE_H
#endif // THIS_FILE_H
]]
}
