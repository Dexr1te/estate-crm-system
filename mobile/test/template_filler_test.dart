import 'package:flutter_test/flutter_test.dart';
import 'package:real_estate_crm/core/models/models.dart';
import 'package:real_estate_crm/features/message_templates/domain/template_filler.dart';
import 'package:real_estate_crm/features/message_templates/presentation/widgets/message_template_sheet.dart';

/// Filling a message template: every placeholder becomes its value or
/// nothing, and whatever is left still reads like a message a person wrote.

const _flat = PropertyResponse(
  id: 7,
  title: 'Severny Residence, apartment 84',
  address: 'Severny Residence 12',
  city: 'Almaty',
  price: 28000000,
);

final _everything = templateValues(
  clientName: ' Irina Sokolova ',
  agentName: 'Maria Kim',
  listing: _flat,
  link: 'https://crm.test/l/abc',
);

final _noListing =
    templateValues(clientName: 'Irina Sokolova', agentName: 'Maria Kim');

const _offer = 'Hello, {client}! I have a property that may suit you:\n'
    '{listing}\n{address}\n{price}\n{link}\n{agent}';

void main() {
  test('each placeholder is filled from the client, the agent and the listing',
      () {
    expect(
        fillTemplate(_offer, _everything),
        [
          'Hello, Irina Sokolova! I have a property that may suit you:',
          'Severny Residence, apartment 84',
          'Severny Residence 12, Almaty',
          r'$28.0M',
          'https://crm.test/l/abc',
          'Maria Kim',
        ].join('\n'));
  });

  test('without a listing its lines go, and nothing in braces is left', () {
    final text = fillTemplate(_offer, _noListing);
    expect(
        text,
        'Hello, Irina Sokolova! I have a property that may suit you:\n'
        'Maria Kim');
    expect(text, isNot(contains('{')));
    expect(text, isNot(contains('}')));
  });

  test('a line whose placeholders are all empty goes, labels and all', () {
    expect(
        fillTemplate(
            'Good news, {client}.\nNow {price}\n{link}\nCall me', _noListing),
        'Good news, Irina Sokolova.\nCall me');
  });

  test('a listing with no public link simply has no link line', () {
    final values = templateValues(
        clientName: 'Irina', agentName: 'Maria', listing: _flat, link: null);
    expect(fillTemplate('{listing}\n{link}\n{agent}', values),
        'Severny Residence, apartment 84\nMaria');
  });

  test('an empty placeholder mid-sentence leaves no stray commas or spaces',
      () {
    expect(fillTemplate('{client}, see {listing}, {address}.', _noListing),
        'Irina Sokolova, see.');
    expect(
        fillTemplate('Hi {client} , it is {agent} {listing} here!', _noListing),
        'Hi Irina Sokolova, it is Maria Kim here!');
    expect(fillTemplate('{listing}, {client} — {agent}', _noListing),
        'Irina Sokolova — Maria Kim');
  });

  test('unknown placeholders come out empty rather than as braces', () {
    final text = fillTemplate('Dear {name}, this is {agent}. {}', _noListing);
    expect(text, 'Dear, this is Maria Kim.');
  });

  test('an unknown name alone on a line loses the braces, not the line', () {
    expect(fillTemplate('Hello\nViewings on {day} too.\nBye', _noListing),
        'Hello\nViewings on too.\nBye');
    expect(fillTemplate('{price} {day}\nBye', _noListing), 'Bye',
        reason: 'the known placeholder on it came out empty');
  });

  test('names match without regard to case or inner spaces', () {
    expect(fillTemplate('{ Client } / {AGENT}', _noListing),
        'Irina Sokolova / Maria Kim');
  });

  test('lines with nothing empty are left exactly as written', () {
    expect(fillTemplate('Price :  as agreed ,  {client}', _noListing),
        'Price :  as agreed ,  Irina Sokolova');
  });

  test('blank lines left behind by dropped ones do not pile up', () {
    expect(fillTemplate('Hello\n\n{link}\n\n{price}\n\nBye', _noListing),
        'Hello\n\nBye');
    expect(fillTemplate('{link}\nHello\n{price}', _noListing), 'Hello');
  });

  test('a listing without a price or a city says only what it knows', () {
    final values = templateValues(
        clientName: 'Irina',
        listing: const PropertyResponse(id: 3, title: 'Flat on Abay'));
    expect(values['price'], '');
    expect(values['address'], '');
    expect(values['agent'], '');
    expect(
        fillTemplate('{listing}\n{address}\n{price}', values), 'Flat on Abay');
  });

  test('text with no placeholders at all goes through untouched', () {
    expect(
        fillTemplate('  Just checking in.  ', _noListing), 'Just checking in.');
  });

  test('the editor names what the app cannot fill, as typed', () {
    expect(unknownPlaceholders('Hi {client}, {Name} and { link } and {x y}'),
        ['{Name}', '{x y}']);
    expect(
        unknownPlaceholders('{client}{agent}{listing}{price}{address}{link}'),
        isEmpty);
  });
}
