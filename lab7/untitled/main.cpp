#include <iostream>
#include <iomanip>
#include <filesystem>

namespace fs = std::filesystem;

extern "C" const char *get_starttime(const char *pid);
extern "C" const char *get_procname(const char *pid);
extern "C" const char *get_procstate(const char *pid);
extern "C" const char *get_cmdline(const char *pid);
extern "C" const char *get_info(const char *pid);
extern "C" void suspend_proc(int pid);
extern "C" void resume_proc(int pid);
extern "C" void complete_proc(int pid);
extern "C" const char *get_btime();

bool isNumber(const std::string &str) {
    for (char const &c: str) {
        if (std::isdigit(c) == 0) {
            return false;
        }
    }
    return true;
}

std::string get_time_format(const char* stime, const char* btime) {
    std::time_t seconds = atol(stime)/100 + atol(btime);
    std::tm* ptm = std::localtime(&seconds);
    char buffer[9];
    std::strftime(buffer, sizeof(buffer), "%H:%M:%S", ptm);
    return std::string(buffer);
}

void print_process_info(const std::string& pid, const char* btime) {
    const char* stime = get_starttime(pid.c_str());
    std::string p_time = get_time_format(stime, btime);
    std::string p_name = get_procname(pid.c_str());
    std::string p_state = get_procstate(pid.c_str());
    std::string p_path = get_cmdline(pid.c_str());

    if (!p_name.empty()) {
        std::cout << std::left << std::setw(10) << pid << std::setw(15) << p_time << std::setw(25)
                  << p_name << std::setw(7) << p_state << std::setw(60) << p_path << "\n";
    }
}

void show_processes_by_name(const std::string& name) {
    std::string path = "/proc";
    const char *btime = get_btime();

    std::cout << std::left << std::setw(10) << "PID" << std::setw(15) << "START TIME" << std::setw(25)
              << "PROC NAME" << std::setw(7) << "STATE" << std::setw(60) << "PATH TO FILE" << "\n";

    for (const auto &entry: fs::directory_iterator(path)) {
        if (fs::is_directory(entry.status())) {
            std::string str = entry.path().filename().string();
            if (isNumber(str) && std::string(get_procname(str.c_str())).find(name) != std::string::npos) {
                print_process_info(str, btime);
            }
        }
    }
}

void get_process_info(std::string pid) {
    std::string info = get_info(pid.c_str());
    if (!info.empty()) {
        std::cout << get_info(pid.c_str()) << "\n";
        return;
    } else {
        std::cout << "Процесс с данным id не существует\n";
    }
}

void complete_process(std::string id) {
    if (isNumber(id.c_str())) {
        complete_proc(stoi(id));
        std::cout << "Процесс заверешен\n";
    }
    else {
        std::cout << "Такого процесса не существует\n";
    }
}

void suspend_process(std::string id) {
    if (isNumber(id.c_str())) {
        suspend_proc(stoi(id));
        std::cout << "Процесс приостановлен\n";
    }
    else {
        std::cout << "Такого процесса не существует\n";
    }
}

void resume_process(std::string id) {
    if (isNumber(id.c_str())) {
        resume_proc(stoi(id));
        std::cout << "Процесс возобновлен\n";
    }
    else {
        std::cout << "Такого процесса не существует\n";
    }
}


void show_all_processes() {
    show_processes_by_name("");
}

int main() {
    std::string choice;
    std::string id;
    std::string name;

    while (true) {
        std::cout << "\nMenu:\n";
        std::cout << "1. Вывести все процессы\n";
        std::cout << "2. Вывести дополнительную информацию о процессе\n";
        std::cout << "3. Вывести процессы с нужным названием\n";
        std::cout << "4. Приостановить выбранный процесс\n";
        std::cout << "5. Возобновить выбранный процесс\n";
        std::cout << "6. Завершить выбранный процесс\n";
        std::cout << "7. Выход\n";
        std::cout << "Введите ваш выбор: ";
        std::cin >> choice;
        if (choice[0] == '7') {
            break;
        }
        if (choice.length() != 1) {
            std::cout << "Неверный выбор, пожалуйста, попробуйте снова.\n";
            continue;
        }
        switch (choice[0]) {
            case '1':
                show_all_processes();
                break;
            case '2':
                std::cout << "Введите номер процесса: ";
                std::cin >> id;
                get_process_info(id);
                break;
            case '3':
                std::cout << "Введите название процесса: ";
                std::cin >> name;
                show_processes_by_name(name);
                break;
            case '4':
                std::cout << "Введите id процесса: ";
                std::cin >> id;
                suspend_process(id);
                break;
            case '5':
                std::cout << "Введите id процесса: ";
                std::cin >> id;
                resume_process(id);
                break;
            case '6':
                std::cout << "Введите id процесса: ";
                std::cin >> id;
                complete_process(id);
                break;

            default:
                std::cout << "Неверный выбор, пожалуйста, попробуйте снова.\n";
                break;
        }
    }

    return 0;
}
