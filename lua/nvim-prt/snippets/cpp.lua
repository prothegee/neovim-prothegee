return {
    int_main = [[
int main() {
    return 0;
}
]],
    int_main_args = [[
int main(int argc, char* argv[]) {
    return 0;
}
]],

    for_i = [[
for (int i = 0; i < var; i++) {
    // TODO
}
]],

    struct_t = [[
struct Struct_t {
    // TODO
}; // Struct_t
]],

    enum_e = [[
enum Enum_e {
    // TODO
} // Enum_e
]],

    include_guard = [[
#ifndef THIS_FILE_H
#define THIS_FILE_H
#endif // THIS_FILE_H
]],

    class_t = [[
class Class_t {
pubic:
    Class_t();
   ~Class_t();
}; // Class_t
]],

    namespace_n = [[
namespace namespace_n {
} // namespace_n
]],
}
