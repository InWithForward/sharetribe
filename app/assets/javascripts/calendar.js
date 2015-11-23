function initCalendar() {
  var events = $.map(JSON.parse($('#listing_availabilities_json').val()), function(e) {
    var start;
    if(e.date)
      start = moment(e.date)
    else
      start = moment();

    start.minute(e.start_at_minute);
    start.hour(e.start_at_hour);
    start.second(0);

    var end;
    if(e.date)
      end = moment(e.date)
    else
      end = moment();

    end.minute(e.end_at_minute);
    end.hour(e.end_at_hour);
    end.second(0);

    if(e.dow)
      var dow = [e.dow];

    return { dow: dow, start: start, end: end };
  });

  var cal = $('#calendar').fullCalendar({
    header: {
      left: 'prev,next',
      center: 'title',
      right: 'month,agendaWeek'
    },
    defaultView: 'agendaWeek',
    allDaySlot: false,
    editable: true,
    slotEventOverlap: false,
    eventDurationEditable: false,
    events: (events || []),
    eventRender: writeJSON,
    eventDrop: writeJSON,
    eventClick: function(calEvent) {
      if(confirm("Delete Time Slot"))
        $('#calendar').fullCalendar('removeEvents', calEvent._id);
    },
    dayClick: function(startDate, jsEvent, view) {
      var dialog = $('#add_availability_dialog').lightbox_me({ centered: true, zIndex: 1000000 });
      if(!startDate.hasTime())
        startDate.hour(13);

      $('#add-recurring').click(function() {
        $('#add-recurring').unbind("click");
        $('#add-once').unbind("click");
        addEvent(true, startDate);
        dialog.trigger('close');
        return false;
      });

      $('#add-once').click(function() {
        $('#add-recurring').unbind("click");
        $('#add-once').unbind("click");
        addEvent(false, startDate);
        dialog.trigger('close');
        return false;
      });

      return false;
    }
  });

  function writeJSON() {
    var indexedEvents = {};
    var events = $.map($('#calendar').fullCalendar('clientEvents'), function(e, i) {
      var dow, startDate;

      // Only write the first recurring event (events with a dow)
      if(e.dow) {
        dow = e.dow[0];
        
        var key = [
          e.start.format('hh:mm'),
          e.end.format('hh:mm'),
          dow
        ].join();

        if(indexedEvents[key] !== undefined)
          return

        indexedEvents[key] = e;
      } else {
        startDate = e.start.format("DD/MM/YYYY");
      }

      return {
        start_at_hour: e.start.hour(),
        start_at_minute: e.start.minute(),
        end_at_hour: e.end.hour(),
        end_at_minute: e.end.minute(),
        dow: dow,
        date: startDate
      };
    });

    $('#listing_availabilities_json').val(JSON.stringify(events));
  };

  function addEvent(recurring, start) {
    var end = start.clone();
    end.add(1.5, 'hour');

    var calEvent;
    if(recurring) {
      calEvent = {
        start: start.format('HH:mm'),
        end: end.format('HH:mm'),
        dow: [start.day()]
      };
    } else {
      calEvent = {
        start: start,
        end: end
      };
    }

    $('#calendar').fullCalendar( 'renderEvent', calEvent, true);
  }
}
