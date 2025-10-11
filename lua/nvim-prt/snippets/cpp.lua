return {

_comment_spacer_c_based = [[
// --------------------------------------------------------- //]],

_head_guard_h = [[
#ifndef $1_H
#define $1_H
#endif // $1_H]],

_head_guard_hh = [[
#ifndef $1_HH
#define $1_HH
#endif // $1_HH]],

_head_guard_hpp = [[
#ifndef $1_HPP
#define $1_HPP
#endif // $1_HPP]],

_namespace_cpp = [[
namespace $1 {
// TODO
} // namespace $1]],

_enum_c_based = [[
enum $1 {
    // TODO
}; // enum $1]],

_enum_class_cpp = [[
enum class $1 {
    // TODO
}; // enum class $1]],

_struct_c_based = [[
struct $1 {
    // TODO
}; // struct $1]],

_class_cpp = [[
class $1 {
public:
    $1();
    ~$1();
}; // class $1]],

_int_main_c_based = [[
int main() {
    return 0;
}]],

_int_main_argcv_c_based = [[
int main(int argc, char* argv[]) {
    return 0;
}]],
}
