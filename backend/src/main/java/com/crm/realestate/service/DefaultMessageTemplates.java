package com.crm.realestate.service;

import java.util.List;

/**
 * The message templates an agency starts with: the few messages an agent writes to clients all
 * day.
 *
 * <p>Written once, as ordinary rows of the agency's own, in one language, exactly like
 * {@link DefaultChecklist}: from then on they are the agency's text, edited by its manager.
 * Translating them on the fly would stop the moment a manager reworded one, and would put two
 * kinds of template in one picker. The language is the manager's when the manager is the one who
 * opens them (their app says which in Accept-Language); otherwise Russian.
 *
 * <p>The listing's details sit on lines of their own. The app drops a line whose placeholders all
 * came out empty, so the same template reads cleanly with a listing chosen and without one.
 */
final class DefaultMessageTemplates {

    record Template(Text en, Text ru, Text kk) {
        Text in(String language) {
            return switch (language) {
                case "en" -> en;
                case "kk" -> kk;
                default -> ru;
            };
        }
    }

    record Text(String title, String body) {
    }

    static final List<Template> TEMPLATES = List.of(
            new Template(
                    new Text("Introduction",
                            "Hello, {client}! This is {agent}, your real estate agent. I will gladly "
                                    + "help you find the right property. When would be a good time to talk?"),
                    new Text("Знакомство",
                            "Здравствуйте, {client}! Меня зовут {agent}, я ваш агент по недвижимости. "
                                    + "С удовольствием помогу подобрать подходящий объект. "
                                    + "Когда вам удобно поговорить?"),
                    new Text("Танысу",
                            "Сәлеметсіз бе, {client}! Мен {agent}, жылжымайтын мүлік жөніндегі агентіңізбін. "
                                    + "Сізге лайықты нысан табуға қуана көмектесемін. "
                                    + "Сөйлесуге қашан ыңғайлы?")),
            new Template(
                    new Text("A listing for you",
                            "Hello, {client}! I have a property that may suit you:\n"
                                    + "{listing}\n{address}\n{price}\n{link}\n{agent}"),
                    new Text("Объект для вас",
                            "Здравствуйте, {client}! Есть объект, который может вам подойти:\n"
                                    + "{listing}\n{address}\n{price}\n{link}\n{agent}"),
                    new Text("Сізге арналған нысан",
                            "Сәлеметсіз бе, {client}! Сізге сәйкес келуі мүмкін нысан бар:\n"
                                    + "{listing}\n{address}\n{price}\n{link}\n{agent}")),
            new Template(
                    new Text("Viewing invitation",
                            "Hello, {client}! Would you like to see this property in person?\n"
                                    + "{listing}\n{address}\n"
                                    + "Tell me a day and time that suit you.\n{agent}"),
                    new Text("Приглашение на просмотр",
                            "Здравствуйте, {client}! Хотите посмотреть этот объект вживую?\n"
                                    + "{listing}\n{address}\n"
                                    + "Напишите, в какой день и время вам удобно.\n{agent}"),
                    new Text("Көрсетілімге шақыру",
                            "Сәлеметсіз бе, {client}! Бұл нысанды өз көзіңізбен көргіңіз келе ме?\n"
                                    + "{listing}\n{address}\n"
                                    + "Өзіңізге ыңғайлы күн мен уақытты жазыңыз.\n{agent}")),
            new Template(
                    new Text("After the viewing",
                            "{client}, thank you for coming to the viewing. What did you think? "
                                    + "If you have any questions, I will gladly answer them.\n{agent}"),
                    new Text("После просмотра",
                            "{client}, спасибо, что пришли на просмотр. Как вам объект? "
                                    + "Если появятся вопросы, с удовольствием отвечу.\n{agent}"),
                    new Text("Көрсетілімнен кейін",
                            "{client}, көрсетілімге келгеніңізге рахмет. Нысан ұнады ма? "
                                    + "Сұрақтарыңыз болса, қуана жауап беремін.\n{agent}")),
            new Template(
                    new Text("Price reduced",
                            "Good news, {client}: the price has come down.\n"
                                    + "{listing}\nNow {price}\n{link}\n{agent}"),
                    new Text("Цена снижена",
                            "Хорошая новость, {client}: цена снижена.\n"
                                    + "{listing}\nТеперь {price}\n{link}\n{agent}"),
                    new Text("Баға төмендеді",
                            "Жақсы жаңалық, {client}: бағасы төмендеді.\n"
                                    + "{listing}\nҚазір {price}\n{link}\n{agent}")));

    private DefaultMessageTemplates() {
    }
}
